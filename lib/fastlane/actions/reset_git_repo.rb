module Fastlane
  module Actions
    # Does a hard reset and clean on the repo
    class ResetGitRepoAction
      def self.run(params)
        if params.include?(:force) || Actions.lane_context[SharedValues::GIT_REPO_WAS_CLEAN_ON_START]
          Actions.sh('git reset --hard HEAD')
          Actions.sh('git clean -qfdx')
          Helper.log.info 'Git repo was reset and cleaned back to a pristine state.'.green
        else
          raise 'This is a destructive and potentially dangerous action. To protect from data loss, please add the `ensure_git_status_clean` action to the beginning of your lane, or if you\'re absolutely sure of what you\'re doing then call this action with the :force option.'.red
        end
      end
    end
  end
end
