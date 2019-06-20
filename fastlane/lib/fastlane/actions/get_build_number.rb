module Fastlane
  module Actions
    module SharedValues
      BUILD_NUMBER ||= :BUILD_NUMBER # originally defined in IncrementBuildNumberAction
    end

    class GetBuildNumberAction < Action
      require 'shellwords'

      def self.run(params)
        # More information about how to set up your project and how it works:
        # https://developer.apple.com/library/ios/qa/qa1827/_index.html

        folder = params[:xcodeproj] ? File.join(params[:xcodeproj], '..') : '.'

        command_prefix = [
          'cd',
          File.expand_path(folder).shellescape,
          '&&'
        ].join(' ')

        command = [
          command_prefix,
          'agvtool',
          'what-version',
          '-terse'
        ].join(' ')

        if Helper.test?
          Actions.lane_context[SharedValues::BUILD_NUMBER] = command
        else
          build_number = Actions.sh(command).split("\n").last.strip

          # Store the number in the shared hash
          Actions.lane_context[SharedValues::BUILD_NUMBER] = build_number
        end
        return build_number
      rescue => ex
        return false if params[:hide_error_when_versioning_disabled]
        UI.error('Before being able to increment and read the version number from your Xcode project, you first need to setup your project properly. Please follow the guide at https://developer.apple.com/library/content/qa/qa1827/_index.html')
        raise ex
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Get the build number of your project"
      end

      def self.details
        [
          "This action will return the current build number set on your project.",
          "You first have to set up your Xcode project, if you haven't done it already: [https://developer.apple.com/library/ios/qa/qa1827/_index.html](https://developer.apple.com/library/ios/qa/qa1827/_index.html)."
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                             env_name: "FL_BUILD_NUMBER_PROJECT",
                             description: "optional, you must specify the path to your main Xcode project if it is not in the project root directory",
                             optional: true,
                             verify_block: proc do |value|
                               UI.user_error!("Please pass the path to the project, not the workspace") if value.end_with?(".xcworkspace")
                               UI.user_error!("Could not find Xcode project") if !File.exist?(value) && !Helper.test?
                             end),
          FastlaneCore::ConfigItem.new(key: :hide_error_when_versioning_disabled,
                             env_name: "FL_BUILD_NUMBER_HIDE_ERROR_WHEN_VERSIONING_DISABLED",
                             description: "Used during `fastlane init` to hide the error message",
                             default_value: false,
                             type: Boolean)
        ]
      end

      def self.output
        [
          ['BUILD_NUMBER', 'The build number']
        ]
      end

      def self.authors
        ["Liquidsoul"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'build_number = get_build_number(xcodeproj: "Project.xcodeproj")'
        ]
      end

      def self.return_type
        :string
      end

      def self.category
        :project
      end
    end
  end
end
