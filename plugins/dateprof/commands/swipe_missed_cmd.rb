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
          list = Swipe.find(target_id: enactor.id, missed: true).select do |swipe|
            enactor.match_for(swipe.character) == :missed
          end.map do |swipe|
            swipe.character.name
          end
          template = BorderedListTemplate.new list, title
          client.emit template.render
        else
          ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|
            swipe = enactor.swipes.find(target_id: model.id).first
            if swipe.nil?
              client.emit_failure t('dateprof.missed_must_swipe')
            else
              swipe.update(missed: true)
              client.emit_success t('global.done')
            end
          end
        end
      end
    end
  end
end
