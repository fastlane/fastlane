module Fastlane
  module Actions
    # Does a hard reset and clean on the repo
    class ResetGitRepoAction < Action
      def self.run(params)
        if params[:force] || params[:force] || Actions.lane_context[SharedValues::GIT_REPO_WAS_CLEAN_ON_START]
          paths = params[:files]

          return paths if Helper.is_test?

          if (paths || []).count == 0
            Actions.sh('git reset --hard HEAD')
            Actions.sh('git clean -qfdx')
            Helper.log.info 'Git repo was reset and cleaned back to a pristine state.'.green
          else
            paths.each do |path|
              Helper.log.warn("Couldn't find file at path '#{path}'") unless File.exist?(path)
              Actions.sh("git checkout -- '#{path}'")
            end
            Helper.log.info "Git cleaned up #{paths.count} files.".green
          end
        else
          raise 'This is a destructive and potentially dangerous action. To protect from data loss, please add the `ensure_git_status_clean` action to the beginning of your lane, or if you\'re absolutely sure of what you\'re doing then call this action with the :force option.'.red
        end
      end

      def self.description
        "Resets git repo to a clean state by discarding uncommited changes"
      end

      def self.details
        [
          "This action will reset your git repo to a clean state, discarding any uncommitted and untracked changes. Useful in case you need to revert the repo back to a clean state, e.g. after the fastlane run.",
          "It's a pretty drastic action so it comes with a sort of safety latch. It will only proceed with the reset if either of these conditions are met:",
          "You have called the ensure_git_status_clean action prior to calling this action. This ensures that your repo started off in a clean state, so the only things that will get destroyed by this action are files that are created as a byproduct of the fastlane run."
        ].join(' ')
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :files,
                                       env_name: "FL_RESET_GIT_FILES",
                                       description: "Array of files the changes should be discarded from. If not given, all files will be discarded",
                                       optional: true,
                                       is_string: false,
                                       verify_block: proc do |value|
                                         raise "Please pass an array only" unless value.kind_of? Array
                                       end),
          FastlaneCore::ConfigItem.new(key: :force,
                                       env_name: "FL_RESET_GIT_FORCE",
                                       description: "Skip verifying of previously clean state of repo. Only recommended in combination with `files` option",
                                       is_string: false,
                                       default_value: false)
        ]
      end

      def self.author
        'lmirosevic'
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
