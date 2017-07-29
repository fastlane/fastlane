module Fastlane
  module Actions
    class ClipboardAction < Action
      def self.run(params)
        UI.message("Storing '#{params[:value]}' in the clipboard 🎨")

        `echo "#{params[:value]}" | tr -d '\n' | pbcopy` # we don't use `sh`, as the command looks ugly
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Copies a given string into the clipboard. Works only on macOS"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :value,
                                       env_name: "FL_CLIPBOARD_VALUE",
                                       description: "The string that should be copied into the clipboard")
        ]
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'clipboard(value: "https://docs.fastlane.tools/")',
          'clipboard(value: lane_context[SharedValues::HOCKEY_DOWNLOAD_LINK] || "")'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
