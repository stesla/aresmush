$:.unshift File.dirname(__FILE__)

module AresMUSH
  module Classifieds
    def self.plugin_dir
      File.dirname(__FILE__)
    end
 
    def self.shortcuts
      Global.read_config("classifieds", "shortcuts")
    end
 
    def self.get_cmd_handler(client, cmd, enactor)      
      return nil
    end

    def self.get_web_request_handler(request)
      case request.cmd
      when 'classifieds'
        return ClassifiedsRequestHandler
      when 'classifiedsAd'
        return ClassifiedsAdRequestHandler
      end
    end
  end
end
