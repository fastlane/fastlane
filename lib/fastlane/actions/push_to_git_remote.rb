module Fastlane
  module Actions
    # Adds a git tag to the current commit
    class PushToGitRemoteAction < Action
      def self.run(params)
        options = params.first

        remote        = (options && options[:remote]) || 'origin'
        force         = (options && options[:force]) || false
        local_branch  = (options && (options[:local_branch] || options[:branch])) || Actions.git_branch.gsub(/#{remote}\//, '') || 'master'
        remote_branch = (options && options[:remote_branch]) || local_branch

        # construct our command as an array of components
        command = [
          'git',
          'push',
          remote,
          "#{local_branch}:#{remote_branch}",
          '--tags'
        ]

        # optionally add the force component
        command << '--force' if force

        # execute our command
        puts Actions.sh('pwd')
        Actions.sh(command.join(' '))

        Helper.log.info 'Sucesfully pushed to remote.'
      end

      def self.description
        "Push local changes to the remote branch"
      end

      def self.available_options
        [
          ['remote', 'The remote to push to. Defaults to `origin`'],
          ['branch', 'The local branch to push from. Defaults to the current branch'],
          ['branch', 'The remote branch to push to. Defaults to the local branch'],
          ['force', 'Force push to remote. Defaults to false']
        ]
      end

      def self.author
        "lmirosevic"
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
