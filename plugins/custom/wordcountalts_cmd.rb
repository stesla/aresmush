module AresMUSH
    module Custom
        class WordCountAltsCmd
            include CommandHandler

            attr_accessor :name
      
            def parse_args
              self.name = enactor_name
            end
      
            def alts
              alt_list = AresCentral.alts(enactor).select { |c| }.map { |c| c.name }
              alt_list.join(" ")
            end

            def format_number(number)
              number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
            end
     
            def handle

              ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|

              fmt_msg = "#{model.ooc_name}'s word count statistics:", alt_list
              msg = fmt_msg.join(" ")
              client.emit_success msg

              end

            end
        end
    end
end