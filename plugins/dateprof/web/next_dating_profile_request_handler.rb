module AresMUSH
  module DateProf
    class NextDatingProfileRequestHandler
      def handle(request)
        error = Website.check_login(request, true)
        return error if error

        enactor = request.enactor
        char = enactor.next_dating_profile

        {
          profile: char.nil? ? nil : {
            id: char.id,
            name: char.name,
            profile_title: Profile.profile_title(char),
            name_and_nickname: Demographics.name_and_nickname(char),
            fullname: char.fullname,
            icon: Website.icon_for_char(char),
            profile_image: Website.get_file_info(char.profile_image),
            handle: char.handle ? char.handle.name : nil,
            dateprof: char.dateprof,
          }
        }
      end
    end
  end
end
