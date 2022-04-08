module AresMUSH
  module DateProf
    class SwipeMatchesTemplate < ErbTemplateRenderer
      attr_accessor :title, :matches

      def initialize(title, enactor)
        @title = title
        @enactor = enactor
        @matches = enactor.matches
        super File.dirname(__FILE__) + "/swipe_matches.erb"
      end
    end
  end
end
