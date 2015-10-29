module Fastlane
  module Actions
    class GetVersionNumberAction < Action
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
          'what-marketing-version',
          '-terse1'
        ].join(' ')

        if Helper.test?
          Actions.lane_context[SharedValues::VERSION_NUMBER] = command
        else

          version_number = (Actions.sh command).split("\n").last

          # Store the number in the shared hash
          Actions.lane_context[SharedValues::VERSION_NUMBER] = version_number
        end
      rescue => ex
        Helper.log.error 'Make sure to follow the steps to setup your Xcode project: https://developer.apple.com/library/ios/qa/qa1827/_index.html'.yellow
        raise ex
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Get the version number of your project"
      end

      def self.details
        [
          "This action will return the current version number set on your project.",
          "You first have to set up your Xcode project, if you haven't done it already:",
          "https://developer.apple.com/library/ios/qa/qa1827/_index.html"
        ].join(' ')
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                             env_name: "FL_VERSION_NUMBER_PROJECT",
                             description: "optional, you must specify the path to your main Xcode project if it is not in the project root directory",
                             optional: true,
                             verify_block: proc do |value|
                               raise "Please pass the path to the project, not the workspace".red if value.include? "workspace"
                               raise "Could not find Xcode project at path '#{File.expand_path(value)}'".red if !File.exist?(value) and !Helper.is_test?
                             end)
        ]
      end

      def self.output
        [
          ['VERSION_NUMBER', 'The version number']
        ]
      end

      def self.authors
        ["Liquidsoul"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end
    end
  end
end
