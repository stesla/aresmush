module AresMUSH
    module Custom
        class WordCountAltsCmd
            include CommandHandler

            attr_accessor :name
      
            def parse_args
              self.name = enactor_name
            end
      
            def format_number(number)
              number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
            end
            
            def handle

              alts = AresCentral.play_screen_alts(enactor)
              ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|

              fmt_msg = "#{model.name} #{model.ooc_name} You did a thing!", "\nAlts:\n"
              msg = fmt_msg.join(" ")
              client.emit_success msg

              end

            end
        end
    end
end