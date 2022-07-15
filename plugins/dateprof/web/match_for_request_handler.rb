module AresMUSH
  module DateProf
    class MatchForRequestHandler
      def handle(request)
        char = Character.find_one_by_name request.args[:id]

        if (!char)
          return { error: t('webportal.not_found') }
        end

        error = Website.check_login(request, true)
        return error if error

        enactor = request.enactor
        dater = Character.find_one_by_name request.args[:dater]
        dater ||= DateProf.can_swipe?(enactor) ? enactor : enactor.dating_alts.first
        return {} unless DateProf.can_swipe?(dater)

        match = dater.match_for(char)
        swipe = dater.swipe_for(char)
        {
          match: match ? match.to_s.humanize.titlecase : nil,
          swipe: swipe ? { type: swipe.type.to_s.humanize.titlecase,  missed: swipe.missed } : nil,
          dating_alts: dater.dating_alts.map {|c| DateProf.format_char(c)},
          matches: DateProf.profile_matches(char, enactor),
        }
      end
    end
  end
end
