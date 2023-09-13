module AresMUSH
  module Classifieds
    class ClassifiedsAdRequestHandler
      def handle(request)
        id = request.args[:id]
        enactor = request.enactor

        ad = ClassifiedsAd[id.to_i]
        if (!ad)
        return { error: t('webportal.not_found') }
        end
        
        error = Website.check_login(request, true)
        return error if error
                            
        {
          id: ad.id,
          title: ad.title,
          author: { 
            name: ad.author.name,
            icon: Website.icon_for_char(ad.author),
          },
          text: ad.text,
          type: ad.type,
          tags: ad.content_tags,
        }
      end
    end
  end
end