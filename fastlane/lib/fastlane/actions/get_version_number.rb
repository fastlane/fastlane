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
          '-terse'
        ].join(' ')

        line = ""
        scheme = params[:scheme] || ""
        results = []

        if Helper.test?
          results = [
            '"SampleProject.xcodeproj/../SchemeA/SchemeA-Info.plist"=4.3.2',
            '"SampleProject.xcodeproj/../SchemeATests/Info.plist"=4.3.2',
            '"SampleProject.xcodeproj/../SchemeB/SchemeB-Info.plist"=5.4.3',
            '"SampleProject.xcodeproj/../SchemeBTests/Info.plist"=5.4.3'
          ]
        else
          results = (Actions.sh command).split("\n")
        end

        if scheme.empty?
          line = results.first unless results.first.nil?
        else
          scheme_string = "/#{scheme}/"
          results.any? do |result|
            if result.include? scheme_string
              line = result
              break
            end
          end
        end

        version_number = line.partition('=').last
        return version_number if Helper.is_test?

        # Store the number in the shared hash
        Actions.lane_context[SharedValues::VERSION_NUMBER] = version_number
      rescue => ex
        UI.error('Make sure to follow the steps to setup your Xcode project: https://developer.apple.com/library/ios/qa/qa1827/_index.html')
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
                               UI.user_error!("Please pass the path to the project, not the workspace") if value.end_with? ".xcworkspace"
                               UI.user_error!("Could not find Xcode project at path '#{File.expand_path(value)}'") if !File.exist?(value) and !Helper.is_test?
                             end),
          FastlaneCore::ConfigItem.new(key: :scheme,
                             env_name: "FL_VERSION_NUMBER_SCHEME",
                             description: "Specify a specific scheme if you have multiple per project, optional",
                             optional: true)
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
