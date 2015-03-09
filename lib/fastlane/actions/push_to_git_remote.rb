module Fastlane
  module Actions
    # Adds a git tag to the current commit
    class PushToGitRemoteAction
      def self.run(params)
        options = params.first

        remote        = (options && options[:remote]) || 'origin'
        force         = (options && options[:force]) || false
        local_branch  = (options && options[:branch]) || 'master'
        remote_branch = (options && options[:branch]) || local_branch

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
    end
  end
end
