module Fastlane
  module Actions
    module SharedValues
      BUILD_NUMBER = :BUILD_NUMBER
    end

    class IncrementBuildNumberAction < Action
      require 'shellwords'

      def self.run(params)
        # More information about how to set up your project and how it works:
        # https://developer.apple.com/library/ios/qa/qa1827/_index.html
        # Attention: This is NOT the version number - but the build number

        begin
          first_param = (params.first rescue nil)

          case first_param
          when NilClass
            custom_number = nil
            folder = '.'
          when Fixnum
            custom_number = first_param
            folder = '.'
          when String
            custom_number = first_param
            folder = '.'
          when Hash
            custom_number = first_param[:build_number]
            folder = first_param[:xcodeproj] ? File.join('.', first_param[:xcodeproj], '..') : '.'
          end
            
          command_prefix = [
            'cd',
            File.expand_path(folder).shellescape,
            '&&'
          ].join(' ')

          command = [
            command_prefix,
            'agvtool',
            custom_number ? "new-version -all #{custom_number}" : 'next-version -all'
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
          ['build_number', 'specify specific build number (optional, omitting it increments by one)'],
          ['xcodeproj', 'optional, you must specify the path to your main Xcode project if it is not in the project root directory']
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
