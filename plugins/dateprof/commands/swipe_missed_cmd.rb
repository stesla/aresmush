module AresMUSH
  module DateProf
    class SwipeMissedCmd
      include CommandHandler

      attr_accessor :name

      def parse_args
        self.name = titlecase_arg(cmd.args)
      end

      def handle
        if self.name.blank?
          title = "#{enactor_name}'s Missed Connections"
          list = enactor.missed_connections.map {|char| char.name}
          template = BorderedListTemplate.new list, title
          client.emit template.render
        else
          ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|
            if enactor.is_admin?
              client.emit_failure t('dateprof.admin_no_swiping')
              return
            end
            error = enactor.swipe(model, :missed)
            if error
              client.emit_failure error
            else
              client.emit_success t('global.done')
            end
          end
        end
      end
    end
  end
end
