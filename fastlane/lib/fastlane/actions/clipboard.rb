module Fastlane
  module Actions
    class ClipboardAction < Action
      def self.run(params)
        value = params[:value]

        truncated_value = value[0..800].gsub(/\s\w+\s*$/, '...')
        UI.message("Storing '#{truncated_value}' in the clipboard 🎨")

        if FastlaneCore::Helper.mac?
          require 'open3'
          Open3.popen3('pbcopy') { |input, _, _| input << value }
        end
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
        ["KrauseFx", "joshdholtz"]
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
