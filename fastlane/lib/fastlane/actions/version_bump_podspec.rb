module Fastlane
  module Actions
    module SharedValues
      PODSPEC_VERSION_NUMBER = :PODSPEC_VERSION_NUMBER
    end

    class VersionBumpPodspecAction < Action
      def self.run(params)
        podspec_path = params[:path]

        UI.user_error!("Could not find podspec file at path #{podspec_path}") unless File.exist?(podspec_path)

        version_podspec_file = Helper::PodspecHelper.new(podspec_path, params[:require_variable_prefix])

        if params[:version_number]
          new_version = params[:version_number]
        elsif params[:version_appendix]
          new_version = version_podspec_file.update_version_appendix(params[:version_appendix])
        else
          new_version = version_podspec_file.bump_version(params[:bump_type])
        end

        version_podspec_file.update_podspec(new_version)

        Actions.lane_context[SharedValues::PODSPEC_VERSION_NUMBER] = new_version
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Increment or set the version in a podspec file"
      end

      def self.details
        [
          "You can use this action to manipulate any 'version' variable contained in a ruby file.",
          "For example, you can use it to bump the version of a CocoaPods' podspec file.",
          "It also supports versions that are not semantic: `1.4.14.4.1`.",
          "For such versions, there is an option to change the appendix (e.g. `4.1`)."
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_VERSION_BUMP_PODSPEC_PATH",
                                       description: "You must specify the path to the podspec file to update",
                                       code_gen_sensitive: true,
                                       default_value: Dir["*.podspec"].last,
                                       default_value_dynamic: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass a path to the `version_bump_podspec` action") if value.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :bump_type,
                                       env_name: "FL_VERSION_BUMP_PODSPEC_BUMP_TYPE",
                                       description: "The type of this version bump. Available: patch, minor, major",
                                       default_value: "patch",
                                       verify_block: proc do |value|
                                         UI.user_error!("Available values are 'patch', 'minor' and 'major'") unless ['patch', 'minor', 'major'].include?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :version_number,
                                       env_name: "FL_VERSION_BUMP_PODSPEC_VERSION_NUMBER",
                                       description: "Change to a specific version. This will replace the bump type value",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :version_appendix,
                                       env_name: "FL_VERSION_BUMP_PODSPEC_VERSION_APPENDIX",
                                       description: "Change version appendix to a specific value. For example 1.4.14.4.1 -> 1.4.14.5",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :require_variable_prefix,
                                       env_name: "FL_VERSION_BUMP_PODSPEC_VERSION_REQUIRE_VARIABLE_PREFIX",
                                       description: "true by default, this is used for non CocoaPods version bumps only",
                                       type: Boolean,
                                       default_value: true)
        ]
      end

      def self.output
        [
          ['PODSPEC_VERSION_NUMBER', 'The new podspec version number']
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
          'version = version_bump_podspec(path: "TSMessages.podspec", bump_type: "patch")',
          'version = version_bump_podspec(path: "TSMessages.podspec", version_number: "1.4")'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
