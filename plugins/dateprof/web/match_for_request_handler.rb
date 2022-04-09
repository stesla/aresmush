module AresMUSH
  module DateProf
    class MatchForRequestHandler
      def handle(request)
        char = Character.find_one_by_name request.args[:id]
        enactor = request.enactor

        if (!char)
          return { error: t('webportal.not_found') }
        end

        error = Website.check_login(request, true)
        return error if error
        return {} unless DateProf.can_swipe?(enactor)

        match = enactor.match_for(char)
        swipe = enactor.swipe_for(char)
        {
          match: match ? match.to_s.humanize.titlecase : nil,
          swipe: swipe ? { type: swipe.type.to_s.humanize.titlecase,  missed: swipe.missed } : nil,
        }
      end
    end
  end
end
