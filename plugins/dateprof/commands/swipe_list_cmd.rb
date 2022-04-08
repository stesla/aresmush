module AresMUSH
  module DateProf
    class SwipeListCmd
      include CommandHandler
      include SwipeCommandHandler

      attr_accessor :type

      def parse_args
        self.type = swipe_type_arg(cmd.args) unless cmd.args.blank?
      end

      def check_type
        Swipe.check_type(self.type)
      end
      
      def handle
        title = "#{enactor_name}'s #{self.type.to_s.humanize.titlecase} Swipes"
        list = enactor.swipes_of_type(self.type).map {|s| s.target.name}
        template = BorderedListTemplate.new list, title
        client.emit template.render
      end
    end
  end
end
