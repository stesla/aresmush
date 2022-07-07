module AresMUSH
    module Custom
        class WordCountAltsCmd
            include CommandHandler
      
            def format_number(number)
              number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
            end
            
            def handle

              alts = AresCentral.play_screen_alts(enactor)
              alt_names = alts.select.all { |a| }.map { |a| "#{a.name}"}

              fmt_msg = "You did a thing!", "\nAlts:\n", alts.to_s
              msg = fmt_msg.join(" ")
              client.emit_success msg

            end
        end
    end
end