module AresMUSH
    module DateProf
        class DateProfCmd
            include CommandHandler

            attr_accessor :name, :dateprof

            def parse_args
                self.name = cmd.args || enactor_name
            end

            def handle 
                ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|
                    template = BorderedDisplayTemplate.new model.dateprof, "#{model.name}'s Dating Profile:"
                    client.emit template.render
                end
            end
        end
    end
end