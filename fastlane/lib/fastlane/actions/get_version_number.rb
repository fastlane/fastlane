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
        target = params[:target] || ""
        results = []

        if Helper.test?
          results = [
            '$(date +%s)n    /usr/libexec/Plistbuddy -c "Set CFBundleVersion $buildnum" "${plist}"n',
            '"SampleProject.xcodeproj/../TargetA/TargetA-Info.plist"=4.3.2',
            '"SampleProject.xcodeproj/../TargetATests/Info.plist"=4.3.2',
            '"SampleProject.xcodeproj/../TargetB/TargetB-Info.plist"=5.4.3',
            '"SampleProject.xcodeproj/../TargetBTests/Info.plist"=5.4.3',
            '"SampleProject.xcodeproj/../SampleProject/supporting_files/TargetC_internal-Info.plist"=7.5.2',
            '"SampleProject.xcodeproj/../SampleProject/supporting_files/TargetC_production-Info.plist"=6.4.9',
            '"SampleProject.xcodeproj/../SampleProject_tests/Info.plist"=1.0'
          ]
        else
          results = Actions.sh(command).split("\n")
        end

        if target.empty? && scheme.empty?
          # Sometimes the results array contains nonsense as the first element
          # This iteration finds the first 'real' result and returns that
          # emulating the actual behavior or the -terse1 flag correctly
          project_string = ".xcodeproj"
          results.any? do |result|
            if result.include?(project_string)
              line = result
              break
            end
          end
        else
          # This iteration finds the first folder structure or info plist
          # matching the specified target
          scheme_string = "/#{scheme}"
          target_string = "/#{target}/"
          plist_target_string = "/#{target}-"
          results.any? do |result|
            if !target.empty?
              if result.include?(target_string)
                line = result
                break
              elsif result.include?(plist_target_string)
                line = result
                break
              end
            else
              if result.include?(scheme_string)
                line = result
                break
              end
            end
          end
        end

        version_number = line.partition('=').last

        # Store the number in the shared hash
        Actions.lane_context[SharedValues::VERSION_NUMBER] = version_number

        # Return the version number because Swift might need this return value
        return version_number
      rescue => ex
        UI.error('Before being able to increment and read the version number from your Xcode project, you first need to setup your project properly. Please follow the guide at https://developer.apple.com/library/content/qa/qa1827/_index.html')
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
                               UI.user_error!("Please pass the path to the project, not the workspace") if value.end_with?(".xcworkspace")
                               UI.user_error!("Could not find Xcode project at path '#{File.expand_path(value)}'") if !File.exist?(value) and !Helper.is_test?
                             end),
          FastlaneCore::ConfigItem.new(key: :scheme,
                             env_name: "FL_VERSION_NUMBER_SCHEME",
                             description: "Specify a specific scheme if you have multiple per project, optional. " \
                                          "This parameter is deprecated and will be removed in a future release. " \
                                          "Please use the 'target' parameter instead. The behavior of this parameter " \
                                          "is currently undefined if your scheme name doesn't match your target name",
                             optional: true,
                             deprecated: true),
          FastlaneCore::ConfigItem.new(key: :target,
                             env_name: "FL_VERSION_NUMBER_TARGET",
                             description: "Specify a specific target if you have multiple per project, optional",
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
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'version = get_version_number(xcodeproj: "Project.xcodeproj")'
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
