module AresMUSH
    module DateProf
        class SetDateProfCmd
            include CommandHandler

            attr_accessor :name, :dateprof

            def parse_args
                if (cmd.args =~ /.+=.+/)
                    args = cmd.parse_args(ArgParser.arg1_equals_arg2)

                    self.name = titlecase_arg(args.arg1)
                    self.dateprof = args.arg2

                else

                    self.name = enactor_name
                    self.dateprof = cmd.args
                end
            end

            def required_args
                [ self.name, self.dateprof ]
            end

            def handle 
                ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|
                    if (enactor.name == model.name)
                        model.update(dateprof: self.dateprof)
                        client.emit_success t('dateprof.dateprof_set')
                    elsif (Chargen.can_approve?(enactor))
                        model.update(dateprof: self.dateprof)
                        client.emit_success t('dateprof.dateprof_set')
                    else
                        client.emit_failure t('dispatcher.not_allowed')
                    end
                end
            end
        end
    end
end
