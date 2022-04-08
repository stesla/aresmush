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
      actor && actor.is_approved? && !actor.is_admin?
    end
  end
end
