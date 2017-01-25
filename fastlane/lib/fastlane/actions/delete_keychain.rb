require 'shellwords'

module Fastlane
  module Actions
    class DeleteKeychainAction < Action
      def self.run(params)
        original = Actions.lane_context[Actions::SharedValues::ORIGINAL_DEFAULT_KEYCHAIN]

        if params[:name]
          keychain_path = File.expand_path(File.join("~", "Library", "Keychains", params[:name]))
        else
          keychain_path = params[:path]
        end

        if keychain_path.nil?
          UI.user_error!("You either have to set :name or :path")
        end

        Fastlane::Actions.sh("security default-keychain -s #{original}", log: false) unless original.nil?
        Fastlane::Actions.sh "security delete-keychain #{keychain_path.shellescape}", log: false
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
                                       conflicting_options: [:path],
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "KEYCHAIN_PATH",
                                       description: "Keychain path",
                                       conflicting_options: [:name],
                                       optional: true)
        ]
      end

      def self.example_code
        [
          'delete_keychain(name: "KeychainName")',
          'delete_keychain(path: "/keychains/project.keychain")'
        ]
      end

      def self.category
        :misc
      end

      def self.authors
        ["gin0606", "koenpunt"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
