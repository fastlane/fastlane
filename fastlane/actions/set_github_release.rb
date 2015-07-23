module Fastlane
  module Actions
    module SharedValues
      SET_GITHUB_RELEASE_HTML_LINK = :SET_GITHUB_RELEASE_HTML_LINK
    end

    class SetGithubReleaseAction < Action
      def self.run(params)

        Helper.log.info "Repo #{params[:repository_name]}, tag #{params[:tag_name]}."

        # sh "shellcommand ./path"

        # Actions.lane_context[SharedValues::SET_GITHUB_RELEASE_HTML_LINK] = "my_val"
      end



      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "This will create a new release on GitHub from given metadata"
      end

      def self.details
        # Optional:
        # this is your change to provide a more detailed description of this action
        "You can use this action to do cool things"
      end

      def self.available_options
        # Define all options your action supports. 
        
        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :repository_name,
                                       env_name: "FL_SET_GITHUB_RELEASE_REPOSITORY_NAME",
                                       description: "The path to your repo, e.g. 'KrauseFx/fastlane'",
                                       verify_block: Proc.new do |value|
                                          raise "Please only pass the path, e.g. 'KrauseFx/fastlane'".red if value.include?"github.com"
                                          raise "Please only pass the path, e.g. 'KrauseFx/fastlane'".red if value.split('/').count != 2
                                       end),
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "FL_SET_GITHUB_RELEASE_API_TOKEN",
                                       description: "Personal API Token for GitHub - generate one at https://github.com/settings/tokens",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :tag_name,
                                       env_name: "FL_SET_GITHUB_RELEASE_TAG_NAME",
                                       description: "Pass in the tag name",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :commitish,
                                       env_name: "FL_SET_GITHUB_RELEASE_COMMITISH",
                                       description: "If provided tag doesn't exist, a new one will be created on the provided branch/commit",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :name,
                                       env_name: "FL_SET_GITHUB_RELEASE_NAME",
                                       description: "Name of this release",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :description,
                                       env_name: "FL_SET_GITHUB_RELEASE_DESCRIPTION",
                                       description: "Description of this release",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :is_draft,
                                       env_name: "FL_SET_GITHUB_RELEASE_IS_DRAFT",
                                       description: "Whether the release should be marked as draft",
                                       optional: true,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :is_prerelease,
                                       env_name: "FL_SET_GITHUB_RELEASE_IS_PRERELEASE",
                                       description: "Whether the release should be marked as prerelease",
                                       optional: true,
                                       default_value: false)
        ]
      end

      def self.output
        [
          ['SET_GITHUB_RELEASE_HTML_LINK', 'Link to your created release']
        ]
      end

      def self.authors
        ["czechboy0"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end