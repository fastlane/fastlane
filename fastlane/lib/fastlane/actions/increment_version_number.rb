module Fastlane
  module Actions
    module SharedValues
      VERSION_NUMBER = :VERSION_NUMBER
    end

    class IncrementVersionNumberAction < Action
      require 'shellwords'

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.run(params)
        # More information about how to set up your project and how it works:
        # https://developer.apple.com/library/ios/qa/qa1827/_index.html

        folder = params[:xcodeproj] ? File.join(params[:xcodeproj], '..') : '.'

        command_prefix = [
          'cd',
          File.expand_path(folder).shellescape,
          '&&'
        ].join(' ')

        current_version = `#{command_prefix} agvtool what-marketing-version -terse1`.split("\n").last || ''

        if params[:version_number]
          UI.verbose("Your current version (#{current_version}) does not respect the format A.B.C") unless current_version =~ /\d.\d.\d/

          # Specific version
          next_version_number = params[:version_number]
        else
          if Helper.test?
            version_array = [1, 0, 0]
          else
            UI.user_error!("Your current version (#{current_version}) does not respect the format A.B.C") unless current_version =~ /\d+.\d+.\d+/
            version_array = current_version.split(".").map(&:to_i)
          end

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
          when "specific_version"
            next_version_number = specific_version_number
          end
        end

        command = [
          command_prefix,
          "agvtool new-marketing-version #{next_version_number.to_s.strip}"
        ].join(' ')

        if Helper.test?
          Actions.lane_context[SharedValues::VERSION_NUMBER] = command
        else
          Actions.sh(command)
          Actions.lane_context[SharedValues::VERSION_NUMBER] = next_version_number
        end

        return Actions.lane_context[SharedValues::VERSION_NUMBER]
      rescue => ex
        UI.error('Before being able to increment and read the version number from your Xcode project, you first need to setup your project properly. Please follow the guide at https://developer.apple.com/library/content/qa/qa1827/_index.html')
        raise ex
      end

      def self.description
        "Increment the version number of your project"
      end

      def self.details
        [
          "This action will increment the version number. ",
          "You first have to set up your Xcode project, if you haven't done it already:",
          "https://developer.apple.com/library/ios/qa/qa1827/_index.html"
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :bump_type,
                                       env_name: "FL_VERSION_NUMBER_BUMP_TYPE",
                                       description: "The type of this version bump. Available: patch, minor, major",
                                       default_value: "patch",
                                       verify_block: proc do |value|
                                         UI.user_error!("Available values are 'patch', 'minor' and 'major'") unless ['patch', 'minor', 'major'].include?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :version_number,
                                       env_name: "FL_VERSION_NUMBER_VERSION_NUMBER",
                                       description: "Change to a specific version. This will replace the bump type value",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                                       env_name: "FL_VERSION_NUMBER_PROJECT",
                                       description: "optional, you must specify the path to your main Xcode project if it is not in the project root directory",
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass the path to the project, not the workspace") if value.end_with?(".xcworkspace")
                                         UI.user_error!("Could not find Xcode project") unless File.exist?(value)
                                       end,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['VERSION_NUMBER', 'The new version number']
        ]
      end

      def self.return_type
        :string
      end

      def self.return_value
        "The new version number"
      end

      def self.author
        "serluca"
      end

      def self.example_code
        [
          'increment_version_number # Automatically increment patch version number',
          'increment_version_number(
            bump_type: "patch" # Automatically increment patch version number
          )',
          'increment_version_number(
            bump_type: "minor" # Automatically increment minor version number
          )',
          'increment_version_number(
            bump_type: "major" # Automatically increment major version number
          )',
          'increment_version_number(
            version_number: "2.1.1" # Set a specific version number
          )',
          'increment_version_number(
            version_number: "2.1.1",                # specify specific version number (optional, omitting it increments patch version number)
            xcodeproj: "./path/to/MyApp.xcodeproj"  # (optional, you must specify the path to your main Xcode project if it is not in the project root directory)
          )',
          'version = increment_version_number'
        ]
      end

      def self.category
        :project
      end
    end
  end
end
