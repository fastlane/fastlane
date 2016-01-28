module Fastlane
  module Actions
    module SharedValues
      CHANGELOG = :CHANGELOG
    end

    class ChangelogFromLastTagAction < Action
      def self.run(params)
        lane_name = params[:lane_name].delete(' ') # no spaces allowed

        tag_pattern = params[:pattern] || "#{params[:grouping]}/#{lane_name}/#{params[:prefix]}*"
        Helper.log.info "Searching for last tag matching pattern: '#{tag_pattern}'"

        tags = Actions.sh("git tag --list '#{tag_pattern}' --sort=-v:refname", log: false).chomp

        if tags.length > 0
          from = tags.split("\n")[0]
          Helper.log.info "Found last tag: '#{from}'"
        else
          from = Actions.last_git_tag_name
          Helper.log.info "Could not match pattern. Instead using: '#{from}'".yellow
        end

        to = 'HEAD'
        Helper.log.info "Collecting Git commits between #{from} and #{to}".green
        changelog = Actions.git_log_between(params[:pretty], from, to)
        Actions.lane_context[SharedValues::CHANGELOG] = changelog

        changelog
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "This generates the CHANGELOG from the commits since your last tag"
      end

      def self.details
        "This action uses the same pattern system as the `add_git_tag` action"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :pattern,
                                       env_name: "FL_GIT_TAG_PATTERN",
                                       description: "Define your own tag pattern. This will replace all other parameters",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :grouping,
                                       env_name: "FL_GIT_TAG_GROUPING",
                                       description: "Is used to select which grouping to use in the pattern. Defaults to 'builds'",
                                       default_value: 'builds'),
          FastlaneCore::ConfigItem.new(key: :lane_name,
                                       env_name: "FL_GIT_TAG_LANE_NAME",
                                       description: "Is used to select which lane to use in the pattern. Defaults to current lane",
                                       default_value: Actions.lane_context[Actions::SharedValues::LANE_NAME]),
          FastlaneCore::ConfigItem.new(key: :prefix,
                                       env_name: "FL_GIT_TAG_PREFIX",
                                       description: "Is used to select which prefix to use in the pattern. Defaults to none",
                                       default_value: ''),
          FastlaneCore::ConfigItem.new(key: :pretty,
                                       env_name: 'FL_CHANGELOG_FROM_LAST_TAG_PRETTY',
                                       description: 'The format applied to each commit while generating the collected value',
                                       optional: true,
                                       default_value: '%B',
                                       is_string: true)
        ]
      end

      def self.output
        [
          ['CHANGELOG', 'The changelog String generated from the collected Git commit messages']
        ]
      end

      def self.return_value
        "Returns a string containing your CHANGELOG"
      end

      def self.authors
        ["scottrhoyt"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
