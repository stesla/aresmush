module AresMUSH
    module DateProf
        class ClearDateProfCmd
            include CommandHandler

            attr_accessor :name, :dateprof

            def parse_args
                self.name = cmd.args || enactor_name
            end

            def required_args
                [ self.name ]
            end

            def handle 
                ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|
                    if (enactor.name == model.name)
                        model.update(dateprof: nil)
                        client.emit_success t('dateprof.dateprof_cleared')
                    elsif (Chargen.can_approve?(enactor))
                        model.update(dateprof: nil)
                        client.emit_success t('dateprof.dateprof_cleared')
                    else
                        client.emit_failure t('dispatcher.not_allowed')
                    end
                end
            end
        end
    end
end