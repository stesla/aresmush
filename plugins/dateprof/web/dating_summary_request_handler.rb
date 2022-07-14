module AresMUSH
  module DateProf
    class DatingSummaryRequestHandler
      def handle(request)
        error = Website.check_login(request, true)
        return error if error

        enactor = request.enactor
        return {error: t('dateprof.must_be_approved')} unless enactor.is_approved?

        alts = enactor.alts.select do |alt|
          DateProf.can_swipe? alt
        end.sort do |a,b|
          a.name <=> b.name
        end.map do |alt|
          {
            char: DateProf.format_char(alt),
            hasUnswipedCharacters: !!alt.next_dating_profile,
            matches: DateProf.format_matches(alt.matches),
            matchCount: alt.matches.values.map(&:size).sum,
          }
        end

        {
          alts: alts,
          matchCount: alts.map {|a| a[:matchCount]}.sum,
        }
      end
    end
  end
end
