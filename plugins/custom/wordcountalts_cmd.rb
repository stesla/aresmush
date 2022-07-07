module AresMUSH
    module Custom
        class WordCountAltsCmd
            include CommandHandler
      
            attr_accessor :name
      
            def parse_args
              self.name = cmd.args || enactor_name
            end

            def format_number(number)
              number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
            end
            
            def handle

              alts = AresCentral.play_screen_alts(self.name)
              alt_names = alts.select { |a| }

              fmt_msg = "You did a thing!", "\nAlts:", alt_names
              msg = fmt_msg.join(" ")
              client.emit_success msg

            end
        end
    end
end