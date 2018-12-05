module Fastlane
  module Actions
    # Pushes commits to the remote hg repo
    class HgPushAction < Action
      def self.run(params)
        command = ['hg', 'push']

        command << '--force' if params[:force]
        command << params[:destination] unless params[:destination].empty?

        return command.join(' ') if Helper.test?

        Actions.sh(command.join(' '))
        UI.success('Successfully pushed changes to remote 🚀.')
      end

      def self.description
        "This will push changes to the remote hg repository"
      end

      def self.details
        "The mercurial equivalent of [push_to_git_remote](https://docs.fastlane.tools/actions/push_to_git_remote/). Pushes your local commits to a remote mercurial repo. Useful when local changes such as adding a version bump commit or adding a tag are part of your lane’s actions."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :force,
                                       env_name: "FL_HG_PUSH_FORCE",
                                       description: "Force push to remote",
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :destination,
                                       env_name: "FL_HG_PUSH_DESTINATION",
                                       description: "The destination to push to",
                                       default_value: '',
                                       optional: true)
        ]
      end

      def self.author
        # credits to lmirosevic for original git version
        "sjrmanning"
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'hg_push',
          'hg_push(
            destination: "ssh://hg@repohost.com/owner/repo",
            force: true
          )'
        ]
      end

      def self.category
        :source_control
      end
    end
  end
end
