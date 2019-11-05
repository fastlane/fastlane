module Fastlane
  module Actions
    # Push local changes to the remote branch
    class PushToGitRemoteAction < Action
      def self.run(params)
        local_branch = params[:local_branch]
        local_branch ||= Actions.git_branch.gsub(%r{#{params[:remote]}\/}, '') if Actions.git_branch
        local_branch ||= 'master'

        remote_branch = params[:remote_branch] || local_branch

        # construct our command as an array of components
        command = [
          'git',
          'push',
          params[:remote],
          "#{local_branch.shellescape}:#{remote_branch.shellescape}"
        ]

        # optionally add the tags component
        command << '--tags' if params[:tags]

        # optionally add the force component
        command << '--force' if params[:force]

        # optionally add the force component
        command << '--force-with-lease' if params[:force_with_lease]

        # optionally add the no-verify component
        command << '--no-verify' if params[:no_verify]

        # optionally add the set-upstream component
        command << '--set-upstream' if params[:set_upstream]

        # execute our command
        Actions.sh('pwd')
        return command.join(' ') if Helper.test?

        Actions.sh(command.join(' '))
        UI.message('Successfully pushed to remote.')
      end

      def self.description
        "Push local changes to the remote branch"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :local_branch,
                                       env_name: "FL_GIT_PUSH_LOCAL_BRANCH",
                                       description: "The local branch to push from. Defaults to the current branch",
                                       default_value_dynamic: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :remote_branch,
                                       env_name: "FL_GIT_PUSH_REMOTE_BRANCH",
                                       description: "The remote branch to push to. Defaults to the local branch",
                                       default_value_dynamic: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :force,
                                       env_name: "FL_PUSH_GIT_FORCE",
                                       description: "Force push to remote",
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :force_with_lease,
                                       env_name: "FL_PUSH_GIT_FORCE_WITH_LEASE",
                                       description: "Force push with lease to remote",
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :tags,
                                       env_name: "FL_PUSH_GIT_TAGS",
                                       description: "Whether tags are pushed to remote",
                                       type: Boolean,
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :remote,
                                       env_name: "FL_GIT_PUSH_REMOTE",
                                       description: "The remote to push to",
                                       default_value: 'origin'),
          FastlaneCore::ConfigItem.new(key: :no_verify,
                                       env_name: "FL_GIT_PUSH_USE_NO_VERIFY",
                                       description: "Whether or not to use --no-verify",
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :set_upstream,
                                       env_name: "FL_GIT_PUSH_USE_SET_UPSTREAM",
                                       description: "Whether or not to use --set-upstream",
                                       type: Boolean,
                                       default_value: false)
        ]
      end

      def self.author
        "lmirosevic"
      end

      def self.details
        [
          "Lets you push your local commits to a remote git repo. Useful if you make local changes such as adding a version bump commit (using `commit_version_bump`) or a git tag (using 'add_git_tag') on a CI server, and you want to push those changes back to your canonical/main repo.",
          "If this is a new branch, use the `set_upstream` option to set the remote branch as upstream."
        ].join("\n")
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'push_to_git_remote # simple version. pushes "master" branch to "origin" remote',
          'push_to_git_remote(
            remote: "origin",         # optional, default: "origin"
            local_branch: "develop",  # optional, aliased by "branch", default is set to current branch
            remote_branch: "develop", # optional, default is set to local_branch
            force: true,              # optional, default: false
            force_with_lease: true,   # optional, default: false
            tags: false,              # optional, default: true
            no_verify: true,          # optional, default: false
            set_upstream: true        # optional, default: false
          )'
        ]
      end

      def self.category
        :source_control
      end
    end
  end
end
