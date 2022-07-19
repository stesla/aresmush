module AresMUSH
  module Chargen
    def self.custom_approval(char)
      char.update(can_swipe: true)
    end

    def self.custom_unapproval(char)
      char.update(can_swipe: false)
    end
  end
end
