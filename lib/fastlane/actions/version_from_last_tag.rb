module Fastlane
  module Actions
    module SharedValues
      VERSION_FROM_LAST_TAG = :VERSION_FROM_LAST_TAG
    end

    class VersionFromLastTagAction < Action
      def self.run(params)
        version_to_return = "#{params[:default_version]}"
        regex = "#{params[:regex]}"

        # git fetch will throw an error if no remotes are defined
        remote_count = sh("git remote show | wc -l")
        if remote_count > 0.to_s
          sh("git fetch --tags")
        end

        # Count the tags
        tag_count = sh("git show-ref --tags | wc -l")

        # If we have more than 1 tag try to parse
        if tag_count.to_i > 0
          last_tag = sh("git describe --tags `git rev-list --tags --max-count=1`")
          begin
            result = /#{regex}/.match(last_tag)[1]
            if result.to_s.length > 0
              version_to_return = result
            end
          rescue
            # do nothing in the regex error case
          end
        end

        Helper.log.info "Parsed tag #{version_to_return} 📝.".green
        Actions.lane_context[SharedValues::VERSION_FROM_LAST_TAG] = version_to_return

        return version_to_return
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Fetchs the latest git tag and parses version info in the form of (anything)0.0.0"
      end

      def self.details
        [
          "This action is designed specificlaly for cases where your repo was shallow cloned",
          "It will fetch the last branch tag and try to parse it using a regex.  The default",
          "regex format is ^\\D+([\\.0-9]*) ",
          "     ",
          "",
          "It will look for a sequence of non-digets and then at the first digit it will capture ",
          "any of the following characters:    0 1 2 3 4 5 6 7 8 9 . ",
          "",
          "So for example",
          "  release-1.2   => 1.2",
          "  v1.0          => 1.0",
          "  version1      => 1",
          "  version 1.2.3 => 1.2.3"
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :regex,
                                       env_name: "FL_VERSION_FROM_LAST_TAG_REGEX",
                                       description: "Custom Regex for tag parsing ",
                                       is_string: true, # true: verifies the input is a string, false: every kind of value
                                       default_value: "^\\D+([\\.0-9]*)",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :default_version,
                                       env_name: "FL_VERSION_FROM_LAST_TAG_DEFAULT_VERSION",
                                       description: "Default version if no tags can be found",
                                       is_string: true,
                                       default_value: "0.0.1",
                                       optional: true)
        ]
      end

      def self.output
        [
          ['VERSION_FROM_LAST_TAG', 'Parsed version information as a string']
        ]
      end

      def self.return_value
        "Returns a string of the versinon nubmer such as 0.0.3"
      end

      def self.authors
        ["Jeeftor"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
