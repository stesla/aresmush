module AresMUSH
  module DateProf
    class SwipeListCmd
      include CommandHandler

      attr_accessor :type

      def parse_args
        self.type = downcase_arg(cmd.args).to_sym
      end

      def check_type
        Swipe.check_type(self.type)
      end
      
      def handle
        title = "#{enactor_name}'s #{self.type.to_s.titlecase} Swipes"
        list = enactor.swipes.find(type: self.type).map {|s| s.target.name}
        template = BorderedListTemplate.new list, title
        client.emit template.render
      end
    end
  end
end
