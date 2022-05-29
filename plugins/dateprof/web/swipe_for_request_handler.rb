module AresMUSH
  module DateProf
    class SwipeForRequestHandler
      def handle(request)
        error = Website.check_login(request)
        return error if error

        char = Character.find_one_by_name request.args[:target]

        if (!char)
          return { error: t('webportal.not_found') }
        end

        enactor = request.enactor
        dater = enactor.swiping_with || enactor
        return {error: t('dateprof.must_be_approved')} unless dater.is_approved?
        return {error: t('dateprof.swiper_no_swiping')} unless DateProf.can_swipe?(dater)

        type = request.args[:type].to_sym
        error = Swipe.check_type(type)
        return { error: error } if error

        begin
          {message: dater.swipe(char, type)}
        rescue SwipeError => e
          {error: e.message}
        end
      end
    end
  end
end
