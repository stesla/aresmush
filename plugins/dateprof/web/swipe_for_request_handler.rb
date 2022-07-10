module AresMUSH
  module DateProf
    class SwipeForRequestHandler
      def handle(request)
        error = Website.check_login(request)
        return error if error

        char = Character.find_one_by_name(request.args[:target])

        if (!char)
          return { error: t('webportal.not_found') }
        end

        enactor = request.enactor
        dater = Character.find_one_by_name(request.args[:dater]) || enactor

        return {error: t('dateprof.not_your_alt')} unless AresCentral.is_alt?(dater, enactor)
        return {error: t('dateprof.must_be_approved')} unless dater.is_approved?
        return {error: t('dateprof.swiper_no_swiping')} unless DateProf.can_swipe?(dater)

        type = request.args[:type].to_sym
        error = Swipe.check_type(type)
        return { error: error } if error

        begin
          message = dater.swipe(char, type)
          match = dater.match_for(char)
          swipe = dater.swipe_for(char)
          {
            message: message,
            match: match ? match.to_s.humanize.titlecase : nil,
            swipe: { type: swipe.type.to_s.humanize.titlecase, missed: swipe.missed },
          }
        rescue SwipeError => e
          {
            error: e.message,
          }
        end
      end
    end
  end
end
