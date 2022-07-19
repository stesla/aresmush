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
      actor && actor.can_swipe && actor.idle_state.nil? && !actor.is_npc
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

    def self.profile_matches(char, viewer)
      matches = char.matches.transform_values do |matches|
        matches = matches.select {|c| AresCentral.is_alt?(viewer, c)}
        matches.empty? ? nil : matches
      end.compact
      format_matches(matches)
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

    def self.format_match_summary(character)
      alts = character.dating_alts.sort do |a,b|
        a.name <=> b.name
      end.map do |alt|
        matches = alt.matches
        {
          char: DateProf.format_char(alt),
          hasUnswipedCharacters: !!alt.next_dating_profile,
          matches: DateProf.format_matches(matches),
          matchCount: matches.values.map(&:size).sum,
        }
      end
      {
        alts: alts,
        matchCount: alts.map {|a| a[:matchCount]}.sum,
      }
    end

    def self.match_for_swipes(character, target)
      if (character.nil? || character.type == :skip) && target && target.missed
        return :missed_connection
      elsif character.nil? or target.nil?
        return nil
      end
      case [character.type, target.type]
      when [:interested, :interested] then :solid
      when [:interested, :curious], [:curious, :interested] then :okay
      when [:curious, :curious] then :maybe
      else nil
      end
    end
  end
end
