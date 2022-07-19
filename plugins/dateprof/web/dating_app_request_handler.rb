module AresMUSH
  module DateProf
    class DatingAppRequestHandler
      def handle(request)
        error = Website.check_login(request)
        return error if error

        enactor = request.enactor
        dater = Character.find_one_by_name(request.args[:dater])
        dater ||= DateProf.can_swipe?(enactor) ? enactor : enactor.dating_alts.first

        return {error: t('dateprof.swiper_no_swiping')} unless DateProf.can_swipe?(dater)
        return {error: t('dateprof.not_your_alt')} unless AresCentral.is_alt?(dater, enactor)
        return {error: t('dateprof.must_be_approved')} unless dater.is_approved?

        build_dating_app_web_data(dater)
      end

      def build_dating_app_web_data(dater)
        {
          profile: profile(dater),
          swipes: swipes(dater),
          matches: matches(dater),
          hide_alts: dater.hide_alts,
          dating_alts: dater.dating_alts.map {|c| DateProf.format_char(c)},
        }
      end

      def profile(viewer)
        char = viewer.next_dating_profile
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

      def swipes(viewer)
        [:interested, :curious, :skip, :missed_connection].map do |type|
          characters = viewer.swipes_of_type(type).map(&:target)
          DateProf.format_char_list(type, characters)
        end.reject do |dict|
          dict[:characters].empty?
        end
      end

      def matches(viewer)
        DateProf.format_matches(viewer.matches)
      end
    end
  end
end
