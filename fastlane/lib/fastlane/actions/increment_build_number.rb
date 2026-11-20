module Fastlane
  module Actions
    module SharedValues
      BUILD_NUMBER ||= :BUILD_NUMBER
    end

    class IncrementBuildNumberAction < Action
      require 'fastlane/helper/xcodeproj_helper'

      def self.is_supported?(platform)
        [:ios, :mac, :xros].include?(platform)
      end

      def self.run(params)
        # More information about how to set up your project and how it works:
        # https://developer.apple.com/library/ios/qa/qa1827/_index.html
        # Attention: This is NOT the version number - but the build number
        project = Helper::XcodeprojHelper.get_single_project!(params[:xcodeproj])
        build_number = params[:build_number].to_s.strip
        build_number = next_build_number(project) if build_number.empty?

        changed = Helper::XcodeprojHelper.update_project_build_setting(project, "CURRENT_PROJECT_VERSION", build_number)
        Helper::XcodeprojHelper.save_project_build_setting(project, "CURRENT_PROJECT_VERSION", build_number) if changed[:project]
        changed_info_plists = params[:skip_info_plist] ? [] : Helper::XcodeprojHelper.update_info_plist_value(project, "CFBundleVersion", build_number)
        unless changed.values.any? || changed_info_plists.any? || stores_build_number?(project, build_number)
          UI.user_error!("Could not store the build number #{build_number} in the project. Set CURRENT_PROJECT_VERSION in the project's build settings, so that this action has a build setting to update.")
        end

        return Actions.lane_context[SharedValues::BUILD_NUMBER] = build_number
      end

      # Returns whether a build configuration, an xcconfig file, or an Info.plist file of the project holds the build number.
      # The action asks this when it changed nothing. The project then either had the build number already, or it sets
      # CURRENT_PROJECT_VERSION nowhere and has no literal CFBundleVersion, so the action had nothing to update.
      def self.stores_build_number?(project, build_number)
        build_configurations = ([project] + project.targets).flat_map(&:build_configurations)
        build_configurations.any? { |config| config.resolve_build_setting("CURRENT_PROJECT_VERSION") == build_number } ||
          Helper::XcodeprojHelper.info_plist_values(project, "CFBundleVersion").include?(build_number)
      end

      # Adds one to the whole-number part of the current build number, so "41" and "41.2" both become "42".
      def self.next_build_number(project)
        (Helper::XcodeprojHelper.current_build_number!(project).to_i + 1).to_s
      end

      def self.description
        "Increment the build number of your project"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :build_number,
                                       env_name: "FL_BUILD_NUMBER_BUILD_NUMBER",
                                       description: "Change to a specific version. When you provide this parameter, Apple Generic Versioning does not have to be enabled",
                                       optional: true,
                                       skip_type_validation: true), # allow Integer, String
          FastlaneCore::ConfigItem.new(key: :skip_info_plist,
                                       env_name: "FL_BUILD_NUMBER_SKIP_INFO_PLIST",
                                       description: "Don't update Info.plist files when updating the build version",
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                                       env_name: "FL_BUILD_NUMBER_PROJECT",
                                       description: "optional, you must specify the path to your main Xcode project if it is not in the project root directory",
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass the path to the project, not the workspace") if value.end_with?(".xcworkspace")
                                         UI.user_error!("Could not find Xcode project") if !File.exist?(value) && !Helper.test?
                                       end)
        ]
      end

      def self.output
        [
          ['BUILD_NUMBER', 'The new build number']
        ]
      end

      def self.return_value
        "The new build number"
      end

      def self.return_type
        :string
      end

      def self.author
        "KrauseFx"
      end

      def self.example_code
        [
          'increment_build_number # automatically increment by one',
          'increment_build_number(
            build_number: "75" # set a specific number
          )',
          'increment_build_number(
            build_number: 75, # specify specific build number (optional, omitting it increments by one)
            xcodeproj: "./path/to/MyApp.xcodeproj" # (optional, you must specify the path to your main Xcode project if it is not in the project root directory)
          )',
          'build_number = increment_build_number'
        ]
      end

      def self.category
        :project
      end
    end
  end
end
