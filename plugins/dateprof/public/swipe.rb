module AresMUSH
  module DateProf
    class Swipe < Ohm::Model
      include ObjectModel

      reference :character, 'AresMUSH::Character'
      reference :target, 'AresMUSH::Character'
      attribute :type, :type => DataType::Symbol

      index :type

      def self.check_type(type)
        return nil if [:interested, :curious, :skip].include? type
        return t('dateprof.invalid_swipe_type')
      end
    end
  end
end

