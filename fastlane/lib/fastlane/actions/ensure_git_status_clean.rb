module Fastlane
  module Actions
    module SharedValues
      GIT_REPO_WAS_CLEAN_ON_START = :GIT_REPO_WAS_CLEAN_ON_START
    end

    # Raises an exception and stop the lane execution if the repo is not in a clean state
    class EnsureGitStatusCleanAction < Action
      def self.run(params)
        # Build command
        if params[:ignored]
          ignored_mode = params[:ignored]
          ignored_mode = 'no' if ignored_mode == 'none'
          command = "git status --porcelain --ignored='#{ignored_mode}'"
        else
          command = "git status --porcelain"
        end

        # Don't log if manually ignoring files as it will emulate output later
        print_output = params[:ignore_files].nil?
        repo_status = Actions.sh(command, log: print_output)

        # Manual post processing trying to ignore certain file paths
        if (ignore_files = params[:ignore_files])
          repo_status = repo_status.lines.reject do |line|
            path = path_from_git_status_line(line)
            next if path.empty?

            was_found = ignore_files.include?(path)

            UI.message("Ignoring '#{path}'") if was_found

            was_found
          end.join("")

          # Emulate the output format of `git status --porcelain`
          UI.command(command)
          repo_status.lines.each do |line|
            UI.message("▸ " + line.chomp.magenta)
          end
        end

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

      def self.path_from_git_status_line(line)
        # Extract the file path from the line based on https://git-scm.com/docs/git-status#_output.
        # The first two characters indicate the status of the file path (e.g. ' M')
        #  M App/script.sh
        #
        # If the file path is renamed, the original path is also included in the line (e.g. 'R  ORIG_PATH -> PATH')
        # R  App/script.sh -> App/script_renamed.sh
        #
        path = line.match(/^.. (.* -> )?(.*)$/)[2]
        path = path.delete_prefix('"').delete_suffix('"')
        return path
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
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :show_diff,
                                       env_name: "FL_ENSURE_GIT_STATUS_CLEAN_SHOW_DIFF",
                                       description: "The flag whether to show the git diff if the repo is dirty",
                                       optional: true,
                                       default_value: false,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :ignored,
                                       env_name: "FL_ENSURE_GIT_STATUS_CLEAN_IGNORED_FILE",
                                       description: [
                                         "The handling mode of the ignored files. The available options are: `'traditional'`, `'none'` (default) and `'matching'`.",
                                         "Specifying `'none'` to this parameter is the same as not specifying the parameter at all, which means that no ignored file will be used to check if the repo is dirty or not.",
                                         "Specifying `'traditional'` or `'matching'` causes some ignored files to be used to check if the repo is dirty or not (more info in the official docs: https://git-scm.com/docs/git-status#Documentation/git-status.txt---ignoredltmodegt)"
                                       ].join(" "),
                                       optional: true,
                                       verify_block: proc do |value|
                                         mode = value.to_s
                                         modes = %w(traditional none matching)

                                         UI.user_error!("Unsupported mode, must be: #{modes}") unless modes.include?(mode)
                                       end),
          FastlaneCore::ConfigItem.new(key: :ignore_files,
                                       env_name: "FL_ENSURE_GIT_STATUS_CLEAN_IGNORE_FILES",
                                       description: "Array of files to ignore",
                                       optional: true,
                                       type: Array)
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
