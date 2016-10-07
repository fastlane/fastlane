module Fastlane
  module Actions
    class GitPullAction < Action
      def self.run(params)
        commands = []

        unless params[:only_tags]
          commands += ["git pull &&"]
        end

        commands += ["git fetch --tags"]

        Actions.sh(commands.join(' '))
      end

      def self.description
        "Executes a simple git pull command"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :only_tags,
                                       description: "Simply pull the tags, and not bring new commits to the current branch from the remote",
                                       is_string: false,
                                       optional: true,
                                       default_value: false,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass a valid value for only_tags. Use one of the following: true, false") unless value.kind_of?(TrueClass) || value.kind_of?(FalseClass)
                                       end)
        ]
      end

      def self.authors
        ["KrauseFx", "JaviSoto"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'git_pull',
          'git_pull(only_tags: true) # only the tags, no commits'
        ]
      end

      def self.category
        :source_control
      end
    end
  end
end
