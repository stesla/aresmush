module AresMUSH
  module DateProf
    class SwipeMatchesCmd
      include CommandHandler
      include SwipeCommandHandler

      def handle
        title = "#{enactor_name}'s Matches"
        template = SwipeMatchesTemplate.new(title, enactor)
        client.emit template.render
      end
    end
  end
end
