module Fastlane
  module Actions
    module SharedValues
      GIT_REPO_WAS_CLEAN_ON_START = :GIT_REPO_WAS_CLEAN_ON_START
    end

    # Raises an exception and stop the lane execution if the repo is not in a clean state
    class EnsureGitStatusCleanAction
      def self.run(_params)
        require 'rugged'

        repo = Rugged::Repository.discover(File.expand_path(Dir.pwd))

        statuses = []
        repo.status { |_, status| statuses << status }
        dirty = statuses.flatten.reject { |status| status == :ignored }.count > 0

        if !dirty
          Helper.log.info 'Git status is clean, all good! 💪'.green
          Actions.lane_context[SharedValues::GIT_REPO_WAS_CLEAN_ON_START] = true
        else
          raise 'git repository is dirty! Please commit or discard all changes first.'.red if dirty
        end
      end
    end
  end
end
