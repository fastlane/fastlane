module Fastlane
  module Actions
    class GitAddAction < Action
      def self.run(params)
        should_escape = params[:shell_escape]

        if params[:pathspec]
          paths = params[:pathspec]
          success_message = "Successfully added from \"#{paths}\" 💾."
        elsif params[:path]
          paths = params[:path].map do |p|
            shell_escape(p, should_escape)
          end.join(' ')
          success_message = "Successfully added \"#{paths}\" 💾."
        else
          paths = "."
          success_message = "Successfully added all files 💾."
        end

        force = params[:force] ? "--force" : nil

        command = [
          "git",
          "add",
          force,
          paths
        ].compact

        result = Actions.sh(command.join(" "), log: FastlaneCore::Globals.verbose?).chomp
        UI.success(success_message)
        return result
      end

      def self.shell_escape(path, should_escape)
        path = path.shellescape if should_escape
        path
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Directly add the given file or all files"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       description: "The file(s) and path(s) you want to add",
                                       type: Array,
                                       conflicting_options: [:pathspec],
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :shell_escape,
                                       description: "Shell escapes paths (set to false if using wildcards or manually escaping spaces in :path)",
                                       type: Boolean,
                                       default_value: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :force,
                                       description: "Allow adding otherwise ignored files",
                                       type: Boolean,
                                       default_value: false,
                                       optional: true),
          # Deprecated
          FastlaneCore::ConfigItem.new(key: :pathspec,
                                       description: "The pathspec you want to add files from",
                                       conflicting_options: [:path],
                                       optional: true,
                                       deprecated: "Use `--path` instead")
        ]
      end

      def self.return_value
        nil
      end

      def self.authors
        ["4brunu", "antondomashnev"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'git_add',
          'git_add(path: "./version.txt")',
          'git_add(path: ["./version.txt", "./changelog.txt"])',
          'git_add(path: "./Frameworks/*", shell_escape: false)',
          'git_add(path: ["*.h", "*.m"], shell_escape: false)',
          'git_add(path: "./Frameworks/*", shell_escape: false)',
          'git_add(path: "*.txt", shell_escape: false)',
          'git_add(path: "./tmp/.keep", force: true)'
        ]
      end

      def self.category
        :source_control
      end
    end
  end
end
