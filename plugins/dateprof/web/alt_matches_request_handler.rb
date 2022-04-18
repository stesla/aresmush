module AresMUSH
  module DateProf
    class AltMatchesRequestHandler
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
            matches: DateProf.format_matches(alt.matches),
          }
        end

        { alts: alts }
      end
    end
  end
end
