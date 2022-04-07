module AresMUSH
  module DateProf
    class SwipeMissedCmd
      include CommandHandler

      def handle
        title = "#{enactor_name}'s Missed Connections"
        list = enactor.missed_connections.map {|char| char.name}
        template = BorderedListTemplate.new list, title
        client.emit template.render
      end
    end
  end
end
