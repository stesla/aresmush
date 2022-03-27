module AresMUSH
  class Character
    list :dating_queue, 'AresMUSH::Character'
    collection :swipes, 'AresMUSH::DateProf::Swipe'

    def next_dating_profile
      self.refresh_dating_queue! if self.dating_queue.empty?
      return self.dating_queue.first
    end

    def refresh_dating_queue!
      queue = Character.all.reject(&:is_admin?).select(&:is_approved?).reject do |model|
        model.id == self.id
      end.select do |model|
        swipe_for(model).nil?
      end.shuffle
      self.dating_queue.replace(queue)
    end

    def swipe(target, type)
      Global.logger.debug("Swipe: #{self.name} --[#{type}]--> #{target.name}")
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
      end 
      Global.logger.debug(swipe)
    end

    def swipe_for(target)
      AresMUSH::DateProf::Swipe.find(character_id: self.id, target_id: target.id).first
    end
  end
end
