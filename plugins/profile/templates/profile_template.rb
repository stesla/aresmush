module AresMUSH
  module Profile
    class ProfileTemplate < ErbTemplateRenderer
      
      attr_accessor :char
      
      def initialize(enactor, char)
        @char = char
        @enactor = enactor
        @markdown = MarkdownFormatter.new
        super File.dirname(__FILE__) + "/profile.erb"
      end

      def approval_status
        Profile.get_profile_status_message(@char)
      end
      
      def visible_demographics
        Demographics.visible_demographics(@char, @enactor).select { |d| d != 'birthdate' }
      end

      def dating_match?
        @enactor.match_for(@char)
      end

      def dating_match
        match = @enactor.match_for(@char) || :none
        color = case match
                when :solid then "%xh%xb"
                when :okay then "%xh%xc"
                when :maybe then "%xh%xg"
                when :missed_connection then "%xh%xy"
                else ""
                end
        "#{color}#{match.to_s.humanize.titlecase}%xn"
      end

      def dating_profile
        @markdown.to_mush(@char.dateprof)
      end

      def dating_swipe?
        @enactor.swipe_for(@char)
      end

      def dating_swipe
        swipe = @enactor.swipe_for(@char)
        return "None" if swipe.nil?
        return "#{swipe.type.to_s.titlecase}#{swipe.missed ? ' (Missed Connection)' : ''}"
      end

      def demographic(d)
        @char.demographic(d)
      end

      def name
        Demographics.name_and_nickname(@char)
      end
      
      def age
        age = @char.age
        age == 0 ? "" : age
      end
      
      def show_age
        Demographics.age_enabled?
      end
      
      def birthdate
        @char.formatted_birthdate
      end

      def groups
        Demographics.all_groups.keys
      end

      def group(g)
        @char.group(g)
      end

      def rank
        @char.rank
      end
      
      def desc
        @char.description
      end
      
      def status
        Chargen.approval_status(@char)
      end
      
      def alts
        alt_list = AresCentral.alts(@char).select { |c| c != self }.map { |c| c.name }
        alt_list.delete(@char.name)
        alt_list.join(" ")
      end
      
      def hooks        
        formatter = MarkdownFormatter.new
        formatter.to_mush @char.rp_hooks
      end
      
      def last_on
        if (Login.is_online?(@char))
          t('profile.currently_connected')
        else
          OOCTime.local_long_timestr(@enactor, @char.last_on)
        end
      end
      
      def timezone
        @char.timezone
      end
      
      def custom_profile
        !@char.profile.empty?
      end
      
      def handle_name
        @char.handle.name
      end
      
      def unread_mail
        t('profile.unread_message_count', :num => @char.num_unread_mail)
      end
      
      def wiki
        game_site = Game.web_portal_url
        "#{game_site}/char/#{@char.name}"
      end
      
      def handle_profile
        arescentral = Global.read_config("arescentral", "arescentral_url")
        "#{arescentral}/handle/#{@char.handle.name}"
      end
      
      def profile_title
        Profile.profile_title(@char)
      end
    end
  end
end
