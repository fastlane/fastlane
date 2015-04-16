module Fastlane
  module Actions
    module SharedValues
      VERSION_NUMBER = :VERSION_NUMBER
    end

    class IncrementVersionNumberAction < Action
      require 'shellwords'

      def self.is_supported?(type)
        type == :ios
      end

      def self.run(params)
        # More information about how to set up your project and how it works:
        # https://developer.apple.com/library/ios/qa/qa1827/_index.html

        begin
          first_param = (params.first rescue nil)
          folder = '.' #Current folder is the default folder

          case first_param
            when NilClass
              release_task = 'patch' #Patch is the default action
            when String
              release_task = first_param
            when Hash
              release_task = first_param[:release_task] ? first_param[:release_task] : "patch"
              folder = first_param[:xcodeproj] ? File.join('.', first_param[:xcodeproj], '..') : '.'
          end

          # Verify integrity
          case release_task
            when /\d.\d.\d/
              specific_version_number = release_task
              release_task = 'specific_version'
            when "patch"
              release_task = 'patch'
            when "minor"
              release_task = 'minor'
            when "major"
              release_task = "major"
            else
              raise 'Invalid parameter #{release_task}'
          end

          command_prefix = [
              'cd',
              File.expand_path(folder).shellescape,
              '&&'
          ].join(' ')

          if Helper.test?
            version_array = [1,0,0]
          else
            current_version = `#{command_prefix} agvtool what-marketing-version -terse1`.split("\n").last
            raise 'Your current version (#{current_version}) does not respect the format A.B.C' unless current_version.match(/\d.\d.\d/)
            #Check if CFBundleShortVersionString is the same for each occurrence
            allBundles = `#{command_prefix} agvtool what-marketing-version -terse`.split("\n")
            allBundles.each do |bundle|
              raise 'Ensure all you CFBundleShortVersionString are equals in your project ' unless bundle.end_with? "=#{current_version}"
            end
            version_array = current_version.split(".").map(&:to_i)
          end

          case release_task
            when "patch"
              version_array[2] = version_array[2]+1
              next_version_number = version_array.join(".")
            when "minor"
              version_array[1] = version_array[1]+1
              version_array[2] = version_array[2]=0
              next_version_number = version_array.join(".")
            when "major"
              version_array[0] = version_array[0]+1
              version_array[1] = version_array[1]=0
              version_array[1] = version_array[2]=0
              next_version_number = version_array.join(".")
            when "specific_version"
              next_version_number = specific_version_number
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

        rescue => ex
          Helper.log.error 'Make sure to to follow the steps to setup your Xcode project: https://developer.apple.com/library/ios/qa/qa1827/_index.html'.yellow
          raise ex
        end
      end

      def self.description
        "Increment the version number of your project"
      end

      def self.details
        [
          "This action will increment the version number. ", 
          "You first have to set up your Xcode project, if you haven't done it already:",
          "https://developer.apple.com/library/ios/qa/qa1827/_index.html"
        ].join(' ')
      end

      def self.available_options
        [
          ['build_number', 'specify specific build number (optional, omitting it increments by one)'],
          ['xcodeproj', 'optional, you must specify the path to your main Xcode project if it is not in the project root directory']
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
