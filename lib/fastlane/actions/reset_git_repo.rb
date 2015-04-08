module Fastlane
  module Actions
    # Does a hard reset and clean on the repo
    class ResetGitRepoAction
      def self.run(params)
        hash = params.first
        if params.include?(:force) || hash[:force] || Actions.lane_context[SharedValues::GIT_REPO_WAS_CLEAN_ON_START]
          paths = hash[:files]

          if (paths || []).count == 0
            Actions.sh('git reset --hard HEAD')
            Actions.sh('git clean -qfdx')
            Helper.log.info 'Git repo was reset and cleaned back to a pristine state.'.green
          else
            paths.each do |path|
              Helper.log.warn("Couldn't find file at path '#{path}'") unless File.exists?(path)
              Actions.sh("git checkout -- '#{path}'")
            end
            Helper.log.info "Git cleaned up #{paths.count} files.".green
          end
        else
          raise 'This is a destructive and potentially dangerous action. To protect from data loss, please add the `ensure_git_status_clean` action to the beginning of your lane, or if you\'re absolutely sure of what you\'re doing then call this action with the :force option.'.red
        end
      end
    end
  end
end
