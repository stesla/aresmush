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

              msg = "You did a thing. Look at you go!"
              client.emit_success msg

            end
        end
    end
end