module Fastlane
  module Actions
    module SharedValues
    end

    class FastlaneVersionAction < Action
      def self.run(params)
        params = nil unless params.kind_of? Array
        value = (params || []).first
        defined_version = Gem::Version.new(value) if value

        raise "Please pass minimum fastlane version as parameter to fastlane_version".red unless defined_version

        if Gem::Version.new(Fastlane::VERSION) < defined_version
          raise "The Fastfile requires a fastlane version of >= #{defined_version}. You are on #{Fastlane::VERSION}. Please update using `sudo gem update fastlane`.".red
        end

        Helper.log.info "fastlane version valid"
      end

      def self.step_text
        "Verifying required fastlane version"
      end

      def self.author
        "KrauseFx"
      end

      def self.description
        "Verifies the minimum fastlane version required"
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
