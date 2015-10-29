module Fastlane
  module Actions
    class ClearDerivedDataAction < Action
      def self.run(params)
        path = File.expand_path("~/Library/Developer/Xcode/DerivedData")
        FileUtils.rm_rf(path) if File.directory?(path)
        Helper.log.info "Successfully cleraed Derived Data ♻️".green
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Deletes the Xcode Derived Data"
      end

      def self.details
        "Deletes the Derived Data from '~/Library/Developer/Xcode/DerivedData'"
      end

      def self.available_options
        []
      end

      def self.output
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end
