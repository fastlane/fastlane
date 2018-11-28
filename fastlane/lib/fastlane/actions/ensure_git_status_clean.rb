module Fastlane
  module Actions
    module SharedValues
      GIT_REPO_WAS_CLEAN_ON_START = :GIT_REPO_WAS_CLEAN_ON_START
    end

    # Raises an exception and stop the lane execution if the repo is not in a clean state
    class EnsureGitStatusCleanAction < Action
      def self.run(params)
        repo_status = Actions.sh("git status --porcelain")
        repo_clean = repo_status.empty?

        if repo_clean
          UI.success('Git status is clean, all good! 💪')
          Actions.lane_context[SharedValues::GIT_REPO_WAS_CLEAN_ON_START] = true
        else
          error_message = "Git repository is dirty! Please ensure the repo is in a clean state by committing/stashing/discarding all changes first."
          error_message += "\nUncommitted changes:\n#{repo_status}" if params[:show_uncommitted_changes]
          if params[:show_diff]
            repo_diff = Actions.sh("git diff")
            error_message += "\nGit diff: \n#{repo_diff}"
          end
          UI.user_error!(error_message)
        end
      end

      def self.description
        "Raises an exception if there are uncommitted git changes"
      end

      def self.details
        [
          "A sanity check to make sure you are working in a repo that is clean.",
          "Especially useful to put at the beginning of your Fastfile in the `before_all` block, if some of your other actions will touch your filesystem, do things to your git repo, or just as a general reminder to save your work.",
          "Also needed as a prerequisite for some other actions like `reset_git_repo`."
        ].join("\n")
      end

      def self.output
        [
          ['GIT_REPO_WAS_CLEAN_ON_START', 'Stores the fact that the git repo was clean at some point']
        ]
      end

      def self.author
        ["lmirosevic", "antondomashnev"]
      end

      def self.example_code
        [
          'ensure_git_status_clean'
        ]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :show_uncommitted_changes,
                                       env_name: "FL_ENSURE_GIT_STATUS_CLEAN_SHOW_UNCOMMITTED_CHANGES",
                                       description: "The flag whether to show uncommitted changes if the repo is dirty",
                                       optional: true,
                                       default_value: false,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :show_diff,
                                       env_name: "FL_ENSURE_GIT_STATUS_CLEAN_SHOW_DIFF",
                                       description: "The flag whether to show the git diff if the repo is dirty",
                                       optional: true,
                                       default_value: false,
                                       is_string: false)
        ]
      end

      def self.category
        :source_control
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
