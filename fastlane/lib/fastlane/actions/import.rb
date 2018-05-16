module Fastlane
  module Actions
    class ImportAction < Action
      def self.run(params)
        # this is implemented in the fast_file.rb
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Import another Fastfile to use its lanes"
      end

      def self.details
        [
          "This is useful if you have shared lanes across multiple apps and you want to store a Fastfile in a separate folder.",
          "The path must be relative to the Fastfile this is called from."
        ].join("\n")
      end

      def self.available_options
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

      def self.example_code
        [
          'import("./path/to/other/Fastfile")'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
