module AresMUSH
  module DateProf
    class SwipeForRequestHandler
      def handle(request)
        char = Character.find_one_by_name request.args[:target]

        if (!char)
          return { error: t('webportal.not_found') }
        end

        error = Website.check_login(request, true)
        return error if error

        type = request.args[:type].to_sym
        error = Swipe.check_type(type)
        return { error: error } if error

        enactor = request.enactor
        error = enactor.swipe(char, type)
        return { error: error } if error
        match = enactor.match_for(char)
        { match: match ? match.to_s.humanize.titlecase : nil }
      end
    end
  end
end
