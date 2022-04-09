module AresMUSH
  module DateProf
    module SwipeCommandHandler
      def check_enactor
        return t('dateprof.must_be_approved') unless enactor.is_approved?
        return t('dateprof.swiper_no_swiping') unless DateProf.can_swipe?(enactor)
        return nil
      end

      def swipe_type_arg(arg)
        downcase_arg(arg).sub(' ','_').to_sym
      end
    end

    def self.can_swipe?(actor)
      actor && actor.is_approved? && !actor.is_admin? && !actor.is_playerbit?
    end

    def self.swiping_demographics
      Global.read_config('dateprof', 'demographics') || ['gender']
    end

    def self.swiping_groups
      Global.read_config('dateprof', 'groups') || []
    end
  end
end
