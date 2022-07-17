module AresMUSH
  class Character
    list :dating_queue, 'AresMUSH::Character'
    collection :swipes, 'AresMUSH::DateProf::Swipe'
    attribute :hide_alts, :type=> DataType::Boolean, :default => false

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
      queue = Character.all.select do |model|
        next if model.id == self.id
        next unless DateProf.can_swipe?(model)
        next if hide_alts and AresCentral.is_alt?(self, model)
        swipe_for(model).nil?
      end.shuffle
      self.dating_queue.replace(queue)
    end

    def swipe(target, type)
      return swipe_missed(target) if type == :missed_connection
      swipe = swipe_for(target)
      if swipe.nil?
        swipe = AresMUSH::DateProf::Swipe.create(
          character_id: self.id,
          target_id: target.id,
          type: type,
        )
        self.dating_queue.delete(target)
      else
        swipe.update(type: type)
        if type == :skip
          swipe.update(missed: false)
        end
      end 
      swipe = target.swipe_for(self)
      if swipe && swipe.missed && type != :skip
        swipe.update(missed: false)
      end

      match = match_for(target)
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
          match = self.match_for(swipe.target)
          h[match] << swipe.target if match
        end
        missed = self.missed_connections
        h.merge({missed_connection: missed.empty? ? nil : missed}).compact
      end
    end

    def match_for(target)
      me = self.swipe_for(target)
      them = target.swipe_for(self)
      DateProf.match_for_swipes(me, them)
    end

    private

    def swipe_missed(model)
      our_swipe = self.swipe_for(model)
      their_swipe = model.swipe_for(self)
      if !our_swipe || our_swipe.type == :skip
        raise DateProf::SwipeError, t('dateprof.missed_must_swipe')
      elsif their_swipe && their_swipe.type != :skip
        raise DateProf::SwipeError, t('dateprof.already_matched')
      end
      our_swipe.update(missed: !our_swipe.missed)
      our_swipe.missed ? t('dateprof.missed_on') : t('dateprof.missed_off')
    end
  end
end
