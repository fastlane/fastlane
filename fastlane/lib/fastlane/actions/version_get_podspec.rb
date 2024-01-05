module Fastlane
  module Actions
    module SharedValues
      PODSPEC_VERSION_NUMBER ||= :PODSPEC_VERSION_NUMBER # originally defined in VersionBumpPodspecAction
    end

    class VersionGetPodspecAction < Action
      def self.run(params)
        podspec_path = params[:path]

        UI.user_error!("Could not find podspec file at path '#{podspec_path}'") unless File.exist?(podspec_path)

        version_podspec_file = Helper::PodspecHelper.new(podspec_path, params[:require_variable_prefix])

        Actions.lane_context[SharedValues::PODSPEC_VERSION_NUMBER] = version_podspec_file.version_value
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Receive the version number from a podspec file"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_VERSION_PODSPEC_PATH",
                                       description: "You must specify the path to the podspec file",
                                       code_gen_sensitive: true,
                                       default_value: Dir["*.podspec"].last,
                                       default_value_dynamic: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass a path to the `version_get_podspec` action") if value.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :require_variable_prefix,
                                       env_name: "FL_VERSION_BUMP_PODSPEC_VERSION_REQUIRE_VARIABLE_PREFIX",
                                       description: "true by default, this is used for non CocoaPods version bumps only",
                                       type: Boolean,
                                       default_value: true)
        ]
      end

      def self.output
        [
          ['PODSPEC_VERSION_NUMBER', 'The podspec version number']
        ]
      end

      def self.authors
        ["Liquidsoul", "KrauseFx"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'version = version_get_podspec(path: "TSMessages.podspec")'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
