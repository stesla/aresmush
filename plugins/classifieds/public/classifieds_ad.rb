module AresMUSH
    class ClassifiedsAd < Ohm::Model
      include ObjectModel
      include HasContentTags
      
      attribute :type, :type => DataType::Symbol
      attribute :title
      attribute :text
      reference :author, "AresMUSH::Character"
    end
end