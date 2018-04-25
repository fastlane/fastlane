require 'shellwords'

module Fastlane
  module Actions
    # Does a hard reset and clean on the repo
    class ResetGitRepoAction < Action
      def self.run(params)
        if params[:force] || Actions.lane_context[SharedValues::GIT_REPO_WAS_CLEAN_ON_START]
          paths = params[:files]

          return paths if Helper.test?

          if paths.nil?
            Actions.sh('git reset --hard HEAD')

            clean_options = ['q', 'f', 'd']
            clean_options << 'x' if params[:disregard_gitignore]
            clean_command = 'git clean' + ' -' + clean_options.join

            # we want to make sure that we have an array of patterns, and no nil values
            unless params[:exclude].kind_of?(Enumerable)
              params[:exclude] = [params[:exclude]].compact
            end

            # attach our exclude patterns to the command
            clean_command += ' ' + params[:exclude].map { |exclude| '-e ' + exclude.shellescape }.join(' ') unless params[:exclude].count == 0

            Actions.sh(clean_command) unless params[:skip_clean]

            UI.success('Git repo was reset and cleaned back to a pristine state.')
          else
            paths.each do |path|
              UI.important("Couldn't find file at path '#{path}'") unless File.exist?(path)
              Actions.sh("git checkout -- '#{path}'")
            end
            UI.success("Git cleaned up #{paths.count} files.")
          end
        else
          UI.user_error!('This is a destructive and potentially dangerous action. To protect from data loss, please add the `ensure_git_status_clean` action to the beginning of your lane, or if you\'re absolutely sure of what you\'re doing then call this action with the :force option.')
        end
      end

      def self.description
        "Resets git repo to a clean state by discarding uncommitted changes"
      end

      def self.details
        list = <<-LIST.markdown_list
          You have called the `ensure_git_status_clean` action prior to calling this action. This ensures that your repo started off in a clean state, so the only things that will get destroyed by this action are files that are created as a byproduct of the fastlane run.
        LIST

        [
          "This action will reset your git repo to a clean state, discarding any uncommitted and untracked changes. Useful in case you need to revert the repo back to a clean state, e.g. after running _fastlane_.",
          "Untracked files like `.env` will also be deleted, unless `:skip_clean` is true.",
          "It's a pretty drastic action so it comes with a sort of safety latch. It will only proceed with the reset if this condition is met:".markdown_preserve_newlines,
          list
        ].join("\n")
      end

      def self.example_code
        [
          'reset_git_repo',
          'reset_git_repo(force: true) # If you don\'t care about warnings and are absolutely sure that you want to discard all changes. This will reset the repo even if you have valuable uncommitted changes, so use with care!',
          'reset_git_repo(skip_clean: true) # If you want "git clean" to be skipped, thus NOT deleting untracked files like ".env". Optional, defaults to false.',
          'reset_git_repo(
            force: true,
            files: [
              "./file.txt"
            ]
          )'
        ]
      end

      def self.category
        :source_control
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :files,
                                       env_name: "FL_RESET_GIT_FILES",
                                       description: "Array of files the changes should be discarded. If not given, all files will be discarded",
                                       optional: true,
                                       is_string: false,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass an array only") unless value.kind_of?(Array)
                                       end),
          FastlaneCore::ConfigItem.new(key: :force,
                                       env_name: "FL_RESET_GIT_FORCE",
                                       description: "Skip verifying of previously clean state of repo. Only recommended in combination with `files` option",
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :skip_clean,
                                       env_name: "FL_RESET_GIT_SKIP_CLEAN",
                                       description: "Skip 'git clean' to avoid removing untracked files like `.env`",
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :disregard_gitignore,
                                       env_name: "FL_RESET_GIT_DISREGARD_GITIGNORE",
                                       description: "Setting this to true will clean the whole repository, ignoring anything in your local .gitignore. Set this to true if you want the equivalent of a fresh clone, and for all untracked and ignore files to also be removed",
                                       is_string: false,
                                       optional: true,
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :exclude,
                                       env_name: "FL_RESET_GIT_EXCLUDE",
                                       description: "You can pass a string, or array of, file pattern(s) here which you want to have survive the cleaning process, and remain on disk, e.g. to leave the `artifacts` directory you would specify `exclude: 'artifacts'`. Make sure this pattern is also in your gitignore! See the gitignore documentation for info on patterns",
                                       is_string: false,
                                       optional: true)
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
