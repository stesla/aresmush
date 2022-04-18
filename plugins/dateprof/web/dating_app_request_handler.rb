module AresMUSH
  module DateProf
    class DatingAppRequestHandler
      attr_accessor :enactor

      def handle(request)
        self.enactor = request.enactor
        error = Website.check_login(request)
        return error if error
        return {error: t('dateprof.must_be_approved')} unless enactor.is_approved?
        return {error: t('dateprof.swiper_no_swiping')} unless DateProf.can_swipe?(enactor)
        {
          profile: profile,
          swipes: swipes,
          matches: matches,
          hide_alt_matches: enactor.hide_alt_matches
        }
      end

      def profile
        char = enactor.next_dating_profile
        return nil if char.nil?
        DateProf.format_char(char).tap do |dict|
          facts = []
          DateProf.swiping_demographics.each do |key|
            facts << {name: key.titlecase, value: char.demographics[key]}
          end
          DateProf.swiping_groups.each do |key|
            facts << {name: key.titlecase, value: char.groups[key]}
          end
          dict[:facts] = facts
        end
      end

      def swipes
        [:interested, :curious, :skip, :missed_connection].map do |type|
          characters = enactor.swipes_of_type(type).map(&:target)
          DateProf.format_char_list(type, characters)
        end.reject do |dict|
          dict[:characters].empty?
        end
      end

      def matches
        DateProf.format_matches(enactor.matches)
      end
    end
  end
end
