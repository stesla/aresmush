module AresMUSH
  module DateProf
    class DatingAppRequestHandler
      def handle(request)
        enactor = request.enactor
        dater = enactor.swiping_with

        if dater.nil?
          dating_alts = enactor.dating_alts
          dater = dating_alts.empty? ? enactor : dating_alts.first
          enactor.update(swiping_with: dater)
        end

        error = Website.check_login(request)
        return error if error

        return {error: t('dateprof.must_be_approved')} unless dater.is_approved?
        return {error: t('dateprof.swiper_no_swiping')} unless DateProf.can_swipe?(dater)

        build_dating_app_web_data(dater)
      end

      def build_dating_app_web_data(dater)
        {
          profile: profile(dater),
          swipes: swipes(dater),
          matches: matches(dater),
          hide_alts: dater.hide_alts,
          swiping_with: DateProf.format_char(dater),
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
