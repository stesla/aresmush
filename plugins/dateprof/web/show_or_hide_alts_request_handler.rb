module AresMUSH
  module DateProf
    class ShowOrHideAltsRequestHandler
      def handle(request)
        error = Website.check_login(request)
        return error if error

        enactor = request.enactor
        dater = enactor.swiping_with || enactor

        return {error: t('dateprof.must_be_approved')} unless dater.is_approved?

        option = request.args[:option] && request.args[:option].to_sym
        options = [ :hide, :show ]
        unless options.include? option
          return {error: t('dateprof.invalid_alts_option', options: options.map(&:to_s).join(', '))}
        end

        message = if request.args[:alts] then
          dater.hide_alts!(option == :hide, true)
        else
          return {error: t('dateprof.swiper_no_swiping')} unless DateProf.can_swipe?(dater)
          dater.hide_alts!(option == :hide)
        end

        { message: message }
      end
    end
  end
end
