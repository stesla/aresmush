module AresMUSH
  module DateProf
    class SwipeAltsCmd
      include CommandHandler
      include SwipeCommandHandler

      attr_accessor :option, :target, :flag
      
      def parse_args
        if /=/ =~ cmd.args
          args = cmd.parse_args(ArgParser.arg1_equals_arg2)
          self.target = titlecase_arg(args.arg1)
          self.option = swipe_type_arg(args.arg2)
        else
          args = cmd.parse_args(ArgParser.arg1_slash_optional_arg2)
          self.option = swipe_type_arg(args.arg1)
          self.flag = swipe_type_arg(args.arg2)
        end
      end

      def required_args
        [ self.option ]
      end

      def check_enactor
        return nil if target and Chargen.can_approve?(enactor)
        return t('dispatcher.not_allowed') if target and !enactor.alts.map(&:name).include?(target)
        super
      end

      def check_option
        options = [ :hide, :show ]
        return nil if options.include?(self.option)
        t('dateprof.invalid_alts_option', :options => options.map {|o| o.to_s}.join(', '))
      end

      def check_flag
        return nil unless self.flag
        flags = [ :all ]
        return nil if flags.include?(self.flag)
        t('dateprof.invalid_alts_flag', :flags => flags.map {|o| o.to_s}.join(', '))
      end

      def handle
        if self.target
          ClassTargetFinder.with_a_character(self.target, client, enactor) do |model|
            message = handle_for_char(model)
            client.emit_ooc message
          end
        else
          message = handle_for_char(enactor)
          client.emit_ooc message
        end
      end

      private

      def handle_for_char(char)
        char.hide_alts!(self.option == :hide, self.flag == :all)
      end
    end
  end
end
