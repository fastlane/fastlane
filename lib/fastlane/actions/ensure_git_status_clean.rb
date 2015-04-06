module Fastlane
  module Actions
    module SharedValues
      GIT_REPO_WAS_CLEAN_ON_START = :GIT_REPO_WAS_CLEAN_ON_START
    end

    # Raises an exception and stop the lane execution if the repo is not in a clean state
    class EnsureGitStatusCleanAction

      def self.is_supported?(type)
        true
      end

      def self.run(_params)
        repo_clean = `git status --porcelain`.empty?

        if repo_clean
          Helper.log.info 'Git status is clean, all good! 💪'.green
          Actions.lane_context[SharedValues::GIT_REPO_WAS_CLEAN_ON_START] = true
        else
          raise 'Git repository is dirty! Please ensure the repo is in a clean state by commiting/stashing/discarding all changes first.'.red
        end
      end
    end
  end
end
