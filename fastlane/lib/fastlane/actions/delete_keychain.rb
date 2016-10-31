require 'shellwords'

module Fastlane
  module Actions
    class DeleteKeychainAction < Action
      def self.run(params)
        original = Actions.lane_context[Actions::SharedValues::ORIGINAL_DEFAULT_KEYCHAIN]
        Fastlane::Actions.sh("security default-keychain -s #{original}", log: false) unless original.nil?
        Fastlane::Actions.sh "security delete-keychain #{params[:name].shellescape}", log: false
      end

      def self.details
        "Keychains can be deleted after being creating with `create_keychain`"
      end

      def self.description
        "Delete keychains and remove them from the search list"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :name,
                                       env_name: "KEYCHAIN_NAME",
                                       description: "Keychain name",
                                       optional: false)
        ]
      end

      def self.example_code
        [
          'delete_keychain(name: "KeychainName")'
        ]
      end

      def self.category
        :misc
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
