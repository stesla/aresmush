module AresMUSH
  module DateProf
    class DatingAppRequestHandler
      attr_accessor :enactor

      def handle(request)
        error = Website.check_login(request)
        return error if error

        self.enactor = request.enactor
        {
          profile: profile,
          swipes: swipes,
          missed: missed_connections,
          matches: matches,
        }
      end

      def profile
        char = enactor.next_dating_profile
        format_char(char) unless char.nil?
      end

      def swipes
        [:interested, :curious, :skip, :missed].map do |type|
          characters = enactor.swipes_of_type(type).map(&:target)
          format_char_list(type, characters)
        end
      end

      def missed_connections
        enactor.missed_connections.map {|char| format_char(char)}
      end
  
      def matches
        enactor.swipes.inject({}) do |h, swipe|
          match = enactor.match_for(swipe.target)
          (h[match] ||= []) << swipe.target if match
          h
        end.map do |type, characters|
          format_char_list(type, characters)
        end
      end

      private

      def format_char(char)
        {
          id: char.id,
          name: char.name,
          icon: Website.icon_for_char(char),
          profile_image: Website.get_file_info(char.profile_image),
          dateprof: char.dateprof,
        }
      end

      def format_char_list(type, characters)
        {
          name: type.to_s.titlecase,
          key: type,
          characters: characters.map {|char| format_char(char)}
        }
      end
    end
  end
end
