module Fastlane
  module Actions
    class RemotePluginAction < Action
      def self.run(params)
        UI.success "It works 😇"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "An example action on how you can import remote code to fastlane"
      end

      def self.available_options
        []
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(_platform)
        true
      end
    end
  end
end
