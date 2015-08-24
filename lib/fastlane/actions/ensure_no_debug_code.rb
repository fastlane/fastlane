module Fastlane
  module Actions
    class EnsureNoDebugCodeAction < Action
      def self.run(params)
        command = "grep -R '#{params[:text]}' '#{File.absolute_path(params[:path])}'"
        return command if Helper.is_test?

        Helper.log.info command.yellow
        results = `#{command}` # we don't use `sh` as the return code of grep is wrong for some reason

        # Example Output
        #   ./fastlane.gemspec:  spec.add_development_dependency 'my_word'
        #   ./Gemfile.lock:    my_word (0.10.1)

        found = []
        results.split("\n").each do |current_raw|
          current = current_raw.strip
          if params[:extension]
            if current.include? ".#{params[:extension]}:"
              found << current
            end
          else
            found << current
          end
        end

        raise "Found debug code '#{params[:text]}': \n\n#{found.join("\n")}" if found.count > 0
        Helper.log.info "No debug code found in code base 🐛"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Ensures the given text is nowhere in the code base"
      end

      def self.details
        [
          "Makes sure the given text is nowhere in the code base. This can be used",
          "to check if there is any debug code still in your code base or if you have",
          "things like // TO DO or similar"
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
                                         raise "Couldn't find the folder at '#{File.absolute_path(value)}'".red unless File.directory?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :extension,
                                       env_name: "FL_ENSURE_NO_DEBUG_CODE_EXTENSION",
                                       description: "The extension that should be searched for",
                                       optional: true,
                                       verify_block: proc do |value|
                                         value.delete!('.') if value.include? "."
                                       end)
        ]
      end

      def self.output
        []
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
