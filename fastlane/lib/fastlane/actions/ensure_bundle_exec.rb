module Fastlane
  module Actions
    module SharedValues
    end

    # Raises an exception and stop the lane execution if the repo is not on a specific branch
    class EnsureBundleExecAction < Action
      def self.run(params)
       
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Raises an exception if not on a using bundler"
      end

      def self.details
        [
          "This action will check if you are using bundler."
        ].join("\n")
      end

      def self.available_options
        [
        ]
      end

      def self.output
        []
      end

      def self.author
        ['rishabhtayal']
      end

      def self.example_code
        [
          "ensure_bundle_exec"
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
