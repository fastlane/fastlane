module Fastlane
  module Actions
    class GitCommitAction < Action
      def self.run(params)
        paths = params[:path]
        skip_git_hooks = params[:skip_git_hooks] ? ['--no-verify'] : []

        if params[:allow_nothing_to_commit]
          # Here we check if the path passed in parameter contains any modification
          # and we skip the `git commit` command if there is none.
          # That means you can have other files modified that are not in the path parameter
          # and still make use of allow_nothing_to_commit.
          repo_clean = Actions.sh('git', 'status', *paths, '--porcelain').empty?
          UI.success("Nothing to commit, working tree clean ✅.") if repo_clean
          return if repo_clean
        end

        result = Actions.sh('git', 'commit', '-m', params[:message], *paths, *skip_git_hooks)
        UI.success("Successfully committed \"#{params[:path]}\" 💾.")
        return result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Directly commit the given file with the given message"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       description: "The file(s) or directory(ies) you want to commit. You can pass an array of multiple file-paths or fileglobs \"*.txt\" to commit all matching files. The files already staged but not specified and untracked files won't be committed",
                                       type: Array),
          FastlaneCore::ConfigItem.new(key: :message,
                                       description: "The commit message that should be used"),
          FastlaneCore::ConfigItem.new(key: :skip_git_hooks,
                                       description: "Set to true to pass `--no-verify` to git",
                                       default_value: false,
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :allow_nothing_to_commit,
                                       description: "Set to true to allow commit without any git changes in the files you want to commit",
                                       default_value: false,
                                       type: Boolean,
                                       optional: true)
        ]
      end

      def self.output
      end

      def self.return_value
        nil
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'git_commit(path: "./version.txt", message: "Version Bump")',
          'git_commit(path: ["./version.txt", "./changelog.txt"], message: "Version Bump")',
          'git_commit(path: ["./*.txt", "./*.md"], message: "Update documentation")',
          'git_commit(path: ["./*.txt", "./*.md"], message: "Update documentation", skip_git_hooks: true)'
        ]
      end

      def self.category
        :source_control
      end
    end
  end
end
