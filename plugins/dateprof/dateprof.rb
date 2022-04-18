$:.unshift File.dirname(__FILE__)

module AresMUSH
    module DateProf

        def self.plugin_dir
            File.dirname(__FILE__)
        end

        def self.shortcuts
            Global.read_config("dateprof", "shortcuts")
        end

        def self.get_cmd_handler(client, cmd, enactor)
            case cmd.root
            when "dateprof"
                case cmd.switch
                when "set"
                    return SetDateProfCmd
                when "clear"
                    return ClearDateProfCmd
                else 
                    return DateProfCmd
                end
            when "swipe"
              case cmd.switch
              when "alts"
                return SwipeAltsCmd
              when "list"
                return SwipeListCmd
              when "matches"
                return SwipeMatchesCmd
              when nil
                return SwipeCmd
              end
            end
            nil
        end

        def self.get_web_request_handler(request)
            case request.cmd
            when "altMatches"
              return AltMatchesRequestHandler
            when "datingApp"
              return DatingAppRequestHandler
            when "matchFor"
              return MatchForRequestHandler
            when "showOrHideAltMatches"
              return ShowOrHideAltMatchesRequestHandler
            when "swipeFor"
              return SwipeForRequestHandler
            end
            nil
        end
    end
end
