require 'fastlane_core'
require 'credentials_manager'

module Cryptex
  class Options
    def self.available_options
      
      [
        FastlaneCore::ConfigItem.new(key: :git_url,
                                     env_name: "CRYPTEX_GITURL",
                                     description: "Url to Cryptex Repo",
                                     is_string: false,
                                     default_value: false),
      ]
    end
  end
end
