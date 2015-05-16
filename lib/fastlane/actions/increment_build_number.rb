module Fastlane
  module Actions
    module SharedValues
      BUILD_NUMBER = :BUILD_NUMBER
    end

    class IncrementBuildNumberAction < Action
      require 'shellwords'

      def self.is_supported?(platform)
        [:ios, :mac].include?platform
      end

      def self.run(params)
        # More information about how to set up your project and how it works:
        # https://developer.apple.com/library/ios/qa/qa1827/_index.html
        # Attention: This is NOT the version number - but the build number

        begin
          folder = params[:xcodeproj] ? File.join('.', params[:xcodeproj], '..') : '.'
            
          command_prefix = [
            'cd',
            File.expand_path(folder).shellescape,
            '&&'
          ].join(' ')

          command = [
            command_prefix,
            'agvtool',
            params[:build_number] ? "new-version -all #{params[:build_number]}" : 'next-version -all'
          ].join(' ')

          if Helper.test?
            Actions.lane_context[SharedValues::BUILD_NUMBER] = command
          else

            Actions.sh command

            # Store the new number in the shared hash
            build_number = `#{command_prefix} agvtool what-version`.split("\n").last.to_i

            Actions.lane_context[SharedValues::BUILD_NUMBER] = build_number
          end
        rescue => ex
          Helper.log.error 'Make sure to to follow the steps to setup your Xcode project: https://developer.apple.com/library/ios/qa/qa1827/_index.html'.yellow
          raise ex
        end
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
                                       verify_block: Proc.new do |value|
                                        raise "Please pass the path to the project, not the workspace".red if value.include?"workspace"
                                        raise "Could not find Xcode project".red if (not File.exists?(value) and not Helper.is_test?)
                                       end)
        ]
      end

      def self.output
        [
          ['BUILD_NUMBER', 'The new build number']
        ]
      end

      def self.author
        "KrauseFx"
      end
    end
  end
end
