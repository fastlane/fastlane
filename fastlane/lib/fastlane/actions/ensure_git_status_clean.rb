module Fastlane
  module Actions
    module SharedValues
      GIT_REPO_WAS_CLEAN_ON_START = :GIT_REPO_WAS_CLEAN_ON_START
    end

    # Raises an exception and stop the lane execution if the repo is not in a clean state
    class EnsureGitStatusCleanAction < Action
      def self.run(params)
        repo_clean = `git status --porcelain`.empty?

        if repo_clean
          UI.success('Git status is clean, all good! 💪')
          Actions.lane_context[SharedValues::GIT_REPO_WAS_CLEAN_ON_START] = true
        else
          raise 'Git repository is dirty! Please ensure the repo is in a clean state by commiting/stashing/discarding all changes first.'.red
        end
      end

      def self.description
        "Raises an exception if there are uncommited git changes"
      end

      def self.output
        [
          ['GIT_REPO_WAS_CLEAN_ON_START', 'Stores the fact that the git repo was clean at some point']
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
