module AresMUSH
  module DateProf
    class SwipeMatchesCmd
      include CommandHandler

      def check_admin
        return t('dateprof.admin_no_swiping') if enactor.is_admin?
        return nil
      end

      def handle
        title = "#{enactor_name}'s Matches"
        template = SwipeMatchesTemplate.new(title, enactor)
        client.emit template.render
      end
    end
  end
end
