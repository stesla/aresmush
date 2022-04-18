module AresMUSH
  module DateProf
    class ShowOrHideAltsRequestHandler
      def handle(request)
        error = Website.check_login(request, true)
        return error if error

        enactor = request.enactor
        return {error: t('dateprof.must_be_approved')} unless enactor.is_approved?

        option = request.args[:option] && request.args[:option].to_sym
        options = [ :hide, :show ]
        unless options.include? option
          return {error: t('dateprof.invalid_alts_option', options: options.map(&:to_s).join(', '))}
        end

        message = if request.args[:alts] then
          enactor.hide_alt_matches!(option == :hide, true)
        else
          return {error: t('dateprof.swiper_no_swiping')} unless DateProf.can_swipe?(enactor)
          enactor.hide_alt_matches!(option == :hide)
        end

        { message: message }
      end
    end
  end
end
