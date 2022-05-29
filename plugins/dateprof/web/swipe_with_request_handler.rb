module AresMUSH
  module DateProf
    class SwipeWithRequestHandler
      def handle(request)
        enactor = request.enactor
        dater = Character.find_one_by_name(request.args[:char])

        return {error: t('dateprof.not_your_alt')} unless AresCentral.is_alt?(enactor, dater)

        enactor.swipe_with!(dater)

        return { char: DateProf.format_char(enactor.swiping_with) }
      end
    end
  end
end

