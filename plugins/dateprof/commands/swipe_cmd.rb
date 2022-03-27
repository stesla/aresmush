module AresMUSH
  module DateProf
    class SwipeCmd
      include CommandHandler

      attr_accessor :name, :type

      def parse_args
        return if cmd.args.blank?
        if cmd.args =~ /^.+=.+$/
          args = cmd.parse_args(ArgParser.arg1_equals_arg2)

          self.name = titlecase_arg(args.arg1)
          self.type = downcase_arg(args.arg2).to_sym
        else
          self.type = downcase_arg(cmd.args).to_sym
        end
      end

      def check_enactor
        return t('dateprof.must_be_approved') unless enactor.is_approved?
        return t('dateprof.admin_no_swiping') if enactor.is_admin?
        return nil
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
          enactor.swipe model, self.type
        end
        client.emit_success t('global.done')
      end
    end
  end
end
