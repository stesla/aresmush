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
        format_char(char).tap do |dict|
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
          format_char_list(type, characters)
        end.reject do |dict|
          dict[:characters].empty?
        end
      end

      def matches
        m = enactor.matches
        [:solid, :okay, :maybe, :missed_connection].map do |type|
          next unless m[type]
          format_char_list(type, m[type])
        end.compact
      end

      private

      def format_char(char)
        {
          id: char.id,
          name: char.name,
          icon: Website.icon_for_char(char),
          profile_image: Website.get_file_info(char.profile_image),
          dateprof: Website.format_markdown_for_html(char.dateprof),
        }
      end

      def format_char_list(type, characters)
        {
          name: type.to_s.humanize.titlecase,
          key: type,
          characters: characters.map {|char| format_char(char)}
        }
      end
    end
  end
end
