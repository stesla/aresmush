module AresMUSH
  class Character
    list :dating_queue, 'AresMUSH::Character'
    collection :swipes, 'AresMUSH::DateProf::Swipe'
    attribute :hide_alt_matches, :type=> DataType::Boolean, :default => false

    def hide_alt_matches!(val)
      self.update(hide_alt_matches: val)
      self.hide_alt_matches ? t('dateprof.alt_matches_hidden') : t('dateprof.alt_matches_shown')
    end

    def missed_connections
      AresMUSH::DateProf::Swipe.find(target_id: self.id, missed: true).select do |swipe|
        self.match_for(swipe.character) == :missed_connection
      end.map do |swipe|
        swipe.character
      end
    end

    def next_dating_profile
      self.refresh_dating_queue! if self.dating_queue.empty?
      return self.dating_queue.first
    end

    def refresh_dating_queue!
      queue = Character.all.select do |model|
        model.id != self.id && DateProf.can_swipe?(model) && swipe_for(model).nil?
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
      return nil
    end

    def swipe_for(target)
      self.swipes.find(target_id: target.id).first
    end

    def swipes_of_type(type)
      if type == :missed_connection
        self.swipes.find(missed: true)
      else
        self.swipes.find(type: type)
      end
    end

    def matches
      self.swipes.reject do |swipe|
        self.hide_alt_matches and self.alts.include?(swipe.target)
      end.inject({}) do |h, swipe|
        match = self.match_for(swipe.target)
        (h[match] ||= []) << swipe.target if match
        h
      end.tap do |h|
        missed = self.missed_connections
        h[:missed_connection] = self.missed_connections unless missed.empty?
      end
    end

    def match_for(target)
      me = self.swipe_for(target)
      them = target.swipe_for(self)

      if (me.nil? || me.type == :skip) && them && them.missed
        return :missed_connection
      elsif me.nil? or them.nil?
        return nil
      end
      case [me.type, them.type]
      when [:interested, :interested] then :solid
      when [:interested, :curious], [:curious, :interested] then :okay
      when [:curious, :curious] then :maybe
      else nil
      end
    end

    private

    def swipe_missed(model)
      our_swipe = self.swipe_for(model)
      their_swipe = model.swipe_for(self)
      if !our_swipe || our_swipe.type == :skip
        return t('dateprof.missed_must_swipe')
      elsif their_swipe && their_swipe.type != :skip
        return t('dateprof.already_matched')
      end
      our_swipe.update(missed: !our_swipe.missed)
      return nil
    end
  end
end
