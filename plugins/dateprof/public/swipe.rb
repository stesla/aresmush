module AresMUSH
  module DateProf
    class Swipe < Ohm::Model
      # This class is just around to help with migrating the data to
      # DatingSwipe. Once the data has been migrated, this can be removed in a
      # future patch.
      #
      # To migrate the data do the following command:
      # ruby DateProf::Swipe.all.each{|swipe| DatingSwipe.create(**swipe.attributes); swipe.delete}
      include ObjectModel

      reference :character, 'AresMUSH::Character'
      reference :target, 'AresMUSH::Character'
      attribute :type, :type => DataType::Symbol
      attribute :missed, :type => DataType::Boolean, :default => false
      attribute :match, :type => DataType::Symbol
    end
  end

  class DatingSwipe < Ohm::Model
    include ObjectModel

    reference :character, 'AresMUSH::Character'
    reference :target, 'AresMUSH::Character'
    attribute :type, :type => DataType::Symbol
    attribute :missed, :type => DataType::Boolean, :default => false
    attribute :match, :type => DataType::Symbol

    index :type
    index :missed

    def self.check_type(type)
      return nil if [:interested, :curious, :skip, :missed_connection].include? type
      return t('dateprof.invalid_swipe_type')
    end
  end
end

