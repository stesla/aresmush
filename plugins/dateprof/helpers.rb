module AresMUSH
  module DateProf
    module SwipeType
      def swipe_type_arg(arg)
        downcase_arg(arg).sub(' ','_').to_sym
      end
    end
  end
end
