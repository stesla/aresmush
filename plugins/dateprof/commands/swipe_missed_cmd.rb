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
            our_swipe = enactor.swipe_for(model)
            their_swipe = model.swipe_for(enactor)
            if !our_swipe || our_swipe.type == :skip
              client.emit_failure t('dateprof.missed_must_swipe')
            elsif their_swipe && their_swipe.type != :skip
              client.emit_failure t('dateprof.already_matched')
            else
              our_swipe.update(missed: !our_swipe.missed)
              client.emit_success t('global.done')
            end
          end
        end
      end
    end
  end
end
