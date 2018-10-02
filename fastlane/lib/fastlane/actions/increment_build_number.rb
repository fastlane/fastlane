module Fastlane
  module Actions
    module SharedValues
      BUILD_NUMBER = :BUILD_NUMBER
    end

    class IncrementBuildNumberAction < Action
      require 'shellwords'

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.run(params)
        folder = params[:xcodeproj] ? File.join(params[:xcodeproj], '..') : '.'

        command_prefix = [
          'cd',
          File.expand_path(folder).shellescape,
          '&&'
        ].join(' ')

        command_suffix = [
          '&&',
          'cd',
          '-'
        ].join(' ')

        # More information about how to set up your project and how it works:
        # https://developer.apple.com/library/ios/qa/qa1827/_index.html
        # Attention: This is NOT the version number - but the build number

        agv_enabled = system([command_prefix, 'agvtool what-version', command_suffix].join(' '))
        raise "Apple Generic Versioning is not enabled." unless agv_enabled

        command = [
          command_prefix,
          'agvtool',
          params[:build_number] ? "new-version -all #{params[:build_number].to_s.strip}" : 'next-version -all',
          command_suffix
        ].join(' ')

        output = Actions.sh(command)
        if output.include?('$(SRCROOT)')
          UI.error('Cannot set build number with plist path containing $(SRCROOT)')
          UI.error('Please remove $(SRCROOT) in your Xcode target build settings')
        end

        # Store the new number in the shared hash
        build_number = Actions.sh("#{command_prefix} agvtool what-version", log: false).split("\n").last.strip

        return Actions.lane_context[SharedValues::BUILD_NUMBER] = build_number
      rescue
        UI.user_error!("Apple Generic Versioning is not enabled in this project.\nBefore being able to increment and read the version number from your Xcode project, you first need to setup your project properly. Please follow the guide at https://developer.apple.com/library/content/qa/qa1827/_index.html")
      end

      def self.description
        "Increment the build number of your project"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :build_number,
                                       env_name: "FL_BUILD_NUMBER_BUILD_NUMBER",
                                       description: "Change to a specific version",
                                       optional: true,
                                       is_string: false),
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
