require 'shellwords'

module Fastlane
  module Actions
    class DeleteKeychainAction < Action
      def self.run(params)
        Fastlane::Actions.sh "security delete-keychain #{params[:name].shellescape}", log:false
      end

      def self.description
        "Delete keychains and remove them from the search list"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :name,
                                       env_name: "KEYCHAIN_NAME",
                                       description: "Keychain name",
                                       optional: false),
        ]
      end

      def self.authors
        ["gin0606"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
