module AresMUSH
  module DateProf
    class SwipeCmd
      include CommandHandler
      include SwipeCommandHandler

      attr_accessor :name, :type

      def parse_args
        return if cmd.args.blank?
        if cmd.args =~ /^.+=.+$/
          args = cmd.parse_args(ArgParser.arg1_equals_arg2)

          self.name = titlecase_arg(args.arg1)
          self.type = swipe_type_arg(args.arg2)
        else
          self.type = swipe_type_arg(cmd.args)
        end
      end

      def check_type
        Swipe.check_type(self.type) unless self.type.blank?
      end

      def handle
        if self.type.blank?
          self.show_next_profile
        else
          if self.name.blank?
            self.swipe_next_profile
          else
            self.swipe_target
          end
        end
      end

      def show_next_profile
        target = enactor.next_dating_profile
        if target.blank?
          client.emit_ooc t('dateprof.no_more_profiles')
        else
          template = AresMUSH::Profile::ProfileTemplate.new(enactor, target)
          client.emit template.render
        end
      end

      def swipe_next_profile
        target = enactor.next_dating_profile
        if target.nil?
          client.emit_ooc t('dateprof.no_more_profiles')
        else
          self.name = target.name
          self.swipe_target
        end
      end

      def swipe_target
        ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|
          begin
            message = enactor.swipe(model, self.type)
            client.emit_success message
          rescue SwipeError => e
            client.emit_failure e.message
          end
        end
      end
    end
  end
end
