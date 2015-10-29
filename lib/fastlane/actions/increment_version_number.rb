module Fastlane
  module Actions
    module SharedValues
      VERSION_NUMBER = :VERSION_NUMBER
    end

    class IncrementVersionNumberAction < Action
      require 'shellwords'

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
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
          Helper.log.debug "Your current version (#{current_version}) does not respect the format A.B.C" unless current_version.match(/\d.\d.\d/)

          # Specific version
          next_version_number = params[:version_number]
        else
          if Helper.test?
            version_array = [1, 0, 0]
          else
            raise "Your current version (#{current_version}) does not respect the format A.B.C" unless current_version.match(/\d+.\d+.\d+/)
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
          "agvtool new-marketing-version #{next_version_number}"
        ].join(' ')

        if Helper.test?
          Actions.lane_context[SharedValues::VERSION_NUMBER] = command
        else
          Actions.sh command
          Actions.lane_context[SharedValues::VERSION_NUMBER] = next_version_number
        end

        return Actions.lane_context[SharedValues::VERSION_NUMBER]
      rescue => ex
        Helper.log.error 'Make sure to follow the steps to setup your Xcode project: https://developer.apple.com/library/ios/qa/qa1827/_index.html'.yellow
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
                                         raise "Available values are 'patch', 'minor' and 'major'" unless ['patch', 'minor', 'major'].include? value
                                       end),
          FastlaneCore::ConfigItem.new(key: :version_number,
                                       env_name: "FL_VERSION_NUMBER_VERSION_NUMBER",
                                       description: "Change to a specific version. This will replace the bump type value",
                                       optional: true
                                      ),
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                                       env_name: "FL_VERSION_NUMBER_PROJECT",
                                       description: "optional, you must specify the path to your main Xcode project if it is not in the project root directory",
                                       verify_block: proc do |value|
                                         raise "Please pass the path to the project, not the workspace".red if value.include? "workspace"
                                         raise "Could not find Xcode project".red unless File.exist?(value)
                                       end,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['VERSION_NUMBER', 'The new version number']
        ]
      end

      def self.author
        "serluca"
      end
    end
  end
end
