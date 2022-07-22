module AresMUSH
  class Character
    list :dating_queue, 'AresMUSH::Character'
    collection :swipes, 'AresMUSH::DateProf::Swipe'
    attribute :hide_alts, :type=> DataType::Boolean, :default => false
    attribute :can_swipe, :type=> DataType::Boolean, :default => false

    def dating_alts
      @dating_alts ||= self.alts.select {|alt| DateProf.can_swipe?(alt)}.sort {|a,b| a.name <=> b.name}
    end

    def hide_alts!(val, all=false)
      if all
        dating_alts.map do |alt|
          alt.hide_alts!(val)
        end.last
      else
        self.update(hide_alts: val)
        refresh_dating_queue!
        self.hide_alts ? t('dateprof.alt_matches_hidden') : t('dateprof.alt_matches_shown')
      end
    end

    def missed_connections
      @missed_connections ||= AresMUSH::DateProf::Swipe.find(target_id: self.id, missed: true).select do |swipe|
        self.match_for(swipe.character) == :missed_connection
      end.map do |swipe|
        swipe.character
      end.select {|c| DateProf.can_swipe?(c)}
    end

    def next_dating_profile
      self.refresh_dating_queue! if self.dating_queue.empty?
      while self.dating_queue.first and !DateProf.can_swipe?(self.dating_queue.first)
        self.dating_queue.delete(self.dating_queue.first)
      end
      return self.dating_queue.first
    end

    def refresh_dating_queue!
      ids = Character.all.ids - self.swipes.map {|s| s.target.id}
      queue = Character.fetch(ids).select do |model|
        next if model.id == self.id
        next unless DateProf.can_swipe?(model)
        next if hide_alts and AresCentral.is_alt?(self, model)
        swipe_for(model).nil?
      end.shuffle
      self.dating_queue.replace(queue)
    end

    def swipe(target, type)
      return swipe_missed(target) if type == :missed_connection

      me = swipe_for(target)
      if me.nil?
        me = AresMUSH::DateProf::Swipe.create(
          character_id: self.id,
          target_id: target.id,
          type: type,
        )
        self.dating_queue.delete(target)
      else
        me.update(type: type)
        if type == :skip
          me.update(missed: false)
        end
      end 

      them = target.swipe_for(self)
      if them && them.missed && type != :skip
        them.update(missed: false)
      end

      match = DateProf.match_for_swipes(me, them)
      me.update(match: match)
      them.update(match: match) unless them.nil?

      match ? t("dateprof.matched_#{match}") : t("dateprof.swiped_#{type}")
    end

    def swipe_for(target)
      self.swipes.find(target_id: target.id).first
    end

    def swipes_of_type(type)
      if type == :missed_connection
        self.swipes.find(missed: true)
      else
        self.swipes.find(type: type)
      end.select {|s| DateProf.can_swipe?(s.target)}
    end

    def matches
      @matches ||= begin
        h = Hash.new {|h,k| h[k] = []}
        self.swipes.each do |swipe|
          next unless DateProf.can_swipe?(swipe.target)
          next if self.hide_alts && AresCentral.is_alt?(self, swipe.target)
          h[swipe.match] << swipe.target if swipe.match
        end
        missed = self.missed_connections
        h.merge({missed_connection: missed.empty? ? nil : missed}).compact
      end
    end

    def match_for(target)
      swipe = self.swipe_for(target)
      swipe ? swipe.match : target.match_for(self)
      return swipe.match unless swipe.nil?
      backswipe = target.swipe_for(self)
      return DateProf.match_for_swipes(swipe, backswipe)
    end

    private

    def swipe_missed(model)
      me = self.swipe_for(model)
      them = model.swipe_for(self)
      if !me || me.type == :skip
        raise DateProf::SwipeError, t('dateprof.missed_must_swipe')
      elsif them && them.type != :skip
        raise DateProf::SwipeError, t('dateprof.already_matched')
      end
      me.update(missed: !me.missed)
      them.update(match: DateProf.match_for_swipes(them, me)) unless them.nil?
      me.missed ? t('dateprof.missed_on') : t('dateprof.missed_off')
    end
  end
end
