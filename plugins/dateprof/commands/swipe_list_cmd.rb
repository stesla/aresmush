module AresMUSH
  module DateProf
    class SwipeListCmd
      include CommandHandler

      attr_accessor :type

      def parse_args
        self.type = downcase_arg(cmd.args).to_sym
      end

      def check_admin
        return t('dateprof.admin_no_swiping') if enactor.is_admin?
        return nil
      end

      def check_type
        return nil if self.type == :missed
        Swipe.check_type(self.type)
      end
      
      def handle
        title = "#{enactor_name}'s #{self.type.to_s.titlecase} Swipes"
        list = enactor.swipes_of_type(self.type).map {|s| s.target.name}
        template = BorderedListTemplate.new list, title
        client.emit template.render
      end
    end
  end
end
