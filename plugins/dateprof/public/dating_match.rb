module AresMUSH
  class DatingMatch < Ohm::Model
    include ObjectModel
    reference :character, 'AresMUSH::Character'
    reference :target, 'AresMUSH::Character'
    reference :swipe, 'AresMUSH::DatingSwipe'
    reference :backswipe, 'AresMUSH::DatingSwipe'
    attribute :value, :type => DataType::Symbol

    before_save :update_value!

    def update_value!
      self.value = DateProf.match_for_swipes(self.swipe, self.backswipe)
    end
  end
end
