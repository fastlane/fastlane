module Fastlane
  module Actions
    class EnsureNoDebugCodeAction < Action
      def self.run(params)
        command = "grep -RE '#{params[:text]}' '#{File.absolute_path(params[:path])}'"

        extensions = []
        extensions << params[:extension] unless params[:extension].nil?

        if params[:extensions]
          params[:extensions].each do |extension|
            extension.delete!('.') if extension.include?(".")
            extensions << extension
          end
        end

        if extensions.count > 1
          command << " --include=\\*.{#{extensions.join(',')}}"
        elsif extensions.count > 0
          command << " --include=\\*.#{extensions.join(',')}"
        end

        command << " --exclude #{params[:exclude]}" if params[:exclude]

        if params[:exclude_dirs]
          params[:exclude_dirs].each do |dir|
            command << " --exclude-dir #{dir.shellescape}"
          end
        end

        return command if Helper.test?

        UI.important(command)
        results = `#{command}` # we don't use `sh` as the return code of grep is wrong for some reason

        # Example Output
        #   ./fastlane.gemspec:  spec.add_development_dependency 'my_word'
        #   ./Gemfile.lock:    my_word (0.10.1)

        found = []
        results.split("\n").each do |current_raw|
          found << current_raw.strip
        end

        UI.user_error!("Found debug code '#{params[:text]}': \n\n#{found.join("\n")}") if found.count > 0
        UI.message("No debug code found in code base 🐛")
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Ensures the given text is nowhere in the code base"
      end

      def self.details
        [
          "You don't want any debug code to slip into production.",
          "This can be used to check if there is any debug code still in your codebase or if you have things like `// TO DO` or similar."
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :text,
                                       env_name: "FL_ENSURE_NO_DEBUG_CODE_TEXT",
                                       description: "The text that must not be in the code base"),
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_ENSURE_NO_DEBUG_CODE_PATH",
                                       description: "The directory containing all the source files",
                                       default_value: ".",
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find the folder at '#{File.absolute_path(value)}'") unless File.directory?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :extension,
                                       env_name: "FL_ENSURE_NO_DEBUG_CODE_EXTENSION",
                                       description: "The extension that should be searched for",
                                       optional: true,
                                       verify_block: proc do |value|
                                         value.delete!('.') if value.include?(".")
                                       end),
          FastlaneCore::ConfigItem.new(key: :extensions,
                                       env_name: "FL_ENSURE_NO_DEBUG_CODE_EXTENSIONS",
                                       description: "An array of file extensions that should be searched for",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :exclude,
                                       env_name: "FL_ENSURE_NO_DEBUG_CODE_EXCLUDE",
                                       description: "Exclude a certain pattern from the search",
                                       optional: true,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :exclude_dirs,
                                       env_name: "FL_ENSURE_NO_DEBUG_CODE_EXCLUDE_DIRS",
                                       description: "An array of dirs that should not be included in the search",
                                       optional: true,
                                       type: Array,
                                       is_string: false)
        ]
      end

      def self.output
        []
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.example_code
        [
          'ensure_no_debug_code(text: "// TODO")',
          'ensure_no_debug_code(text: "Log.v",
                          extension: "java")',
          'ensure_no_debug_code(text: "NSLog",
                               path: "./lib",
                          extension: "m")',
          'ensure_no_debug_code(text: "(^#define DEBUG|NSLog)",
                               path: "./lib",
                          extension: "m")',
          'ensure_no_debug_code(text: "<<<<<<",
                         extensions: ["m", "swift", "java"])'
        ]
      end

      def self.category
        :misc
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
