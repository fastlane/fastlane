module Fastlane
  module Actions
    class ClipboardAction < Action
      def self.run(params)
        value = params[:value]

        truncated_value = value[0..800].gsub(/\s\w+\s*$/, '...')
        UI.message("Storing '#{truncated_value}' in the clipboard 🎨")

        FastlaneCore::Clipboard.copy(content: value)
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
        ["KrauseFx", "joshdholtz", "rogerluan"]
      end

      def self.is_supported?(platform)
        FastlaneCore::Clipboard.is_supported?
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
