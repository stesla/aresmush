module AresMUSH
  module DateProf
    module SwipeCommandHandler
      def check_enactor
        return t('dateprof.must_be_approved') unless enactor.is_approved?
        return t('dateprof.swiper_no_swiping') unless DateProf.can_swipe?(enactor)
        return nil
      end

      def swipe_type_arg(arg)
        arg ? downcase_arg(arg).sub(' ','_').to_sym : nil
      end
    end

    class Error < ::StandardError
    end

    class SwipeError < Error
    end

    def self.can_swipe?(actor)
      actor && actor.is_approved? && !actor.is_admin? && !actor.is_playerbit?
    end

    def self.can_swipe_in_portal?(actor)
      actor && !actor.dating_alts.empty?
    end

    def self.show_dating_profile?(char, viewer)
      return false unless char && viewer
      return true if char.name == viewer.name
      return true if Chargen.can_approve?(viewer)
      can_swipe_in_portal?(char)
    end

    def self.swiping_demographics
      Global.read_config('dateprof', 'demographics') || ['gender']
    end

    def self.swiping_groups
      Global.read_config('dateprof', 'groups') || []
    end

    def self.format_char(char)
      {
        id: char.id,
        name: char.name,
        icon: Website.icon_for_char(char),
        profile_image: Website.get_file_info(char.profile_image),
        dateprof: Website.format_markdown_for_html(char.dateprof),
      }
    end

    def self.format_char_list(type, characters)
      {
        name: type.to_s.humanize.titlecase,
        key: type,
        characters: characters.sort {|a,b| a.name <=> b.name}.map {|char| format_char(char)}
      }
    end

    def self.format_matches(matches)
      [:solid, :okay, :maybe, :missed_connection].map do |type|
        next unless matches[type]
        DateProf.format_char_list(type, matches[type])
      end.compact
    end
  end
end
