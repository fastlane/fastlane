module Fastlane
  module Actions
    module SharedValues
      PODSPEC_VERSION_NUMBER = :PODSPEC_VERSION_NUMBER
    end

    class VersionBumpPodspecAction < Action
      def self.run(params)
        podspec_path = params[:path]

        raise "Could not find podspec file at path #{podspec_path}".red unless File.exist? podspec_path

        version_podspec_file = Helper::PodspecHelper.new(podspec_path)

        if params[:version_number]
          new_version = params[:version_number]
        else
          new_version = version_podspec_file.bump_version(params[:bump_type])
        end

        version_podspec_file.update_podspec(new_version)

        Actions.lane_context[SharedValues::PODSPEC_VERSION_NUMBER] = new_version
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Increment or set the version in a podspec file"
      end

      def self.details
        [
          "You can use this action to manipulate any 'version' variable contained in a ruby file.",
          "For example, you can use it to bump the version of a cocoapods' podspec file."
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_VERSION_BUMP_PODSPEC_PATH",
                                       description: "You must specify the path to the podspec file to update",
                                       default_value: Dir["*.podspec"].last,
                                       verify_block: proc do |value|
                                         raise "Please pass a path to the `version_bump_podspec` action".red if value.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :bump_type,
                                       env_name: "FL_VERSION_BUMP_PODSPEC_BUMP_TYPE",
                                       description: "The type of this version bump. Available: patch, minor, major",
                                       default_value: "patch",
                                       verify_block: proc do |value|
                                         raise "Available values are 'patch', 'minor' and 'major'" unless ['patch', 'minor', 'major'].include? value
                                       end),
          FastlaneCore::ConfigItem.new(key: :version_number,
                                       env_name: "FL_VERSION_BUMP_PODSPEC_VERSION_NUMBER",
                                       description: "Change to a specific version. This will replace the bump type value",
                                       optional: true)
        ]
      end

      def self.output
        [
          ['PODSPEC_VERSION_NUMBER', 'The new podspec version number']
        ]
      end

      def self.authors
        ["Liquidsoul", "KrauseFx"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
