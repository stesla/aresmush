module AresMUSH
  module DateProf
    class DatingSummaryRequestHandler
      def handle(request)
        error = Website.check_login(request, true)
        return error if error

        enactor = request.enactor
        return {error: t('dateprof.must_be_approved')} unless enactor.is_approved?

        DateProf.format_match_summary(enactor)
      end
    end
  end
end
