module Fastlane
  module Actions
    module SharedValues
    end

    class FastlaneVersionAction < Action
      def self.run(params)
        params = nil unless params.kind_of?(Array)
        value = (params || []).first
        defined_version = Gem::Version.new(value) if value

        UI.user_error!("Please pass minimum fastlane version as parameter to fastlane_version") unless defined_version

        if Gem::Version.new(Fastlane::VERSION) < defined_version
          error_message = "The Fastfile requires a fastlane version of >= #{defined_version}. You are on #{Fastlane::VERSION}. "
          if Helper.bundler?
            error_message += "Please update using `bundle update fastlane`."
          else
            error_message += "Please update using `sudo gem update fastlane`."
          end
          UI.user_error!(error_message)
        end

        UI.message("Your fastlane version #{Fastlane::VERSION} matches the minimum requirement of #{defined_version}  ✅")
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

      def self.example_code
        ['fastlane_version "1.50.0"']
      end

      def self.details
        [
          "Add this to your `Fastfile` to require a certain version of _fastlane_.",
          "Use it if you use an action that just recently came out and you need it"
        ].join("\n")
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
