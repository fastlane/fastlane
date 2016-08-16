module Fastlane
  module Actions
    class IncrementVersionNumberInPlistAction < Action
      def self.run(params)
        if params[:version_number]
          next_version_number = params[:version_number]
        else
          current_version = GetVersionNumberFromPlistAction.run(xcodeproj: params[:xcodeproj],
                                                                    target: params[:target], build_configuration_name: params[:build_configuration_name])

          version_array = current_version.split(".").map(&:to_i)
          case params[:bump_type]
          when "patch"
            version_array[2] = version_array[2] + 1
            next_version_number = version_array.join(".")
          when "minor"
            version_array[1] = version_array[1] + 1
            version_array[2] = version_array[2] = 0
            next_version_number = version_array.join(".")
          when "major"
            version_array[0] = version_array[0] + 1
            version_array[1] = version_array[1] = 0
            version_array[1] = version_array[2] = 0
            next_version_number = version_array.join(".")
          end
        end

        if Helper.test?
          plist = "/tmp/fastlane/tests/fastlane/Info.plist"
        else
          plist = GetInfoPlistPathAction.run(xcodeproj: params[:xcodeproj],
             target: params[:target],
             build_configuration_name: params[:build_configuration_name])
        end

        SetInfoPlistValueAction.run(path: plist, key: 'CFBundleShortVersionString', value: next_version_number)

        Actions.lane_context[SharedValues::VERSION_NUMBER] = next_version_number
      end

      def self.description
        "Increment the version number of your project"
      end

      def self.details
        [
          "This action will increment the version number directly in Info.plist. "
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :bump_type,
                                       env_name: "FL_VERSION_NUMBER_BUMP_TYPE",
                                       description: "The type of this version bump. Available: patch, minor, major",
                                       default_value: "patch",
                                       verify_block: proc do |value|
                                         UI.user_error!("Available values are 'patch', 'minor' and 'major'") unless ['patch', 'minor', 'major'].include? value
                                       end),
          FastlaneCore::ConfigItem.new(key: :version_number,
                                       env_name: "FL_VERSION_NUMBER_VERSION_NUMBER",
                                       description: "Change to a specific version. This will replace the bump type value",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                                       env_name: "FL_VERSION_NUMBER_PROJECT",
                                       description: "optional, you must specify the path to your main Xcode project if it is not in the project root directory",
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass the path to the project, not the workspace") if value.end_with? ".xcworkspace"
                                         UI.user_error!("Could not find Xcode project") unless File.exist?(value)
                                       end,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :target,
          env_name: "FL_VERSION_NUMBER_TARGET",
                             optional: true,
                             description: "Specify a specific target if you have multiple per project, optional"),
          FastlaneCore::ConfigItem.new(key: :build_configuration_name,
                             optional: true,
                             description: "Specify a specific build configuration if you have different Info.plist build settings for each configuration")
        ]
      end

      def self.output
        [
          ['VERSION_NUMBER', 'The new version number']
        ]
      end

      def self.author
        "SiarheiFedartsou"
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end
    end
  end
end
