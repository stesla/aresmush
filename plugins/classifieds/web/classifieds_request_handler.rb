module AresMUSH
  module Classifieds
    class ClassifiedsRequestHandler
      def handle(request)
        id = request.args[:id]
        enactor = request.enactor

        error = Website.check_login(request, true)
        return error if error

        classifieds = ClassifiedsAd.all.map { |ad| {
          id: ad.id,
          title: ad.title,
          author: {
              name: ad.author.name,
              id: ad.author.id,
              icon: Website.icon_for_char(ad.author),
          },
          text: ad.text,
          tags: ad.content_tags,
        }}

        {
          classifieds: classifieds,
        }
      end
    end
  end
end
