module AresMUSH
  module DateProf
    class SwipeAltsCmd
      include CommandHandler
      include SwipeCommandHandler

      attr_accessor :option
      
      def parse_args
        self.option = !cmd.args ? nil : swipe_type_arg(cmd.args)
      end

      def required_args
        [ self.option ]
      end

      def check_option
        options = [ :hide, :show ]
        return nil if options.include?(self.option)
        t('dateprof.invalid_alts_option', :options => options.map {|o| o.to_s}.join(', '))
      end

      def handle
        message = enactor.hide_alt_matches!(self.option == :hide)
        client.emit_ooc message
      end
    end
  end
end
