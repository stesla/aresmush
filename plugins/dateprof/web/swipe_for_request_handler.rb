module AresMUSH
  module DateProf
    class SwipeForRequestHandler
      def handle(request)
        error = Website.check_login(request, true)
        return error if error

        char = Character.find_one_by_name request.args[:target]

        if (!char)
          return { error: t('webportal.not_found') }
        end

        enactor = request.enactor
        return {error: t('dateprof.must_be_approved')} unless enactor.is_approved?
        return {error: t('dateprof.swiper_no_swiping')} unless DateProf.can_swipe?(enactor)

        type = request.args[:type].to_sym
        error = Swipe.check_type(type)
        return { error: error } if error

        begin
          {message: enactor.swipe(char, type)}
        rescue SwipeError => e
          {error: e.message}
        end
      end
    end
  end
end
