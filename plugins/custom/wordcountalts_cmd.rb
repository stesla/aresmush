module AresMUSH
    module Custom
        class WordCountAltsCmd
            include CommandHandler

            attr_accessor :name
      
            def parse_args
              self.name = enactor_name
            end
      
            def alts
              alt_list = AresCentral.alts(enactor).map { |c| c.name }
            end

            def format_number(number)
              number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
            end
     
            def handle

              ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|
              
              msg = "#{model.ooc_name}'s word count statistics:"
              client.emit_success msg
    
              end

              alts.each {
                |n| 
                current_alt = #{n}
                ClassTargetFinder.with_a_character(current_alt, client, enactor) do |model|
                  client.emit "Current alt is: #{n} - #{model.name}"
                end
              }

            end
        end
    end
end