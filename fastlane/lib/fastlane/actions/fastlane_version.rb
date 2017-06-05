module Fastlane
  module Actions
    module SharedValues
    end

    class FastlaneVersionAction < Action
      def self.run(params)
        params = nil unless params.kind_of?(Array)
        value = (params || []).first
        options = (params and params.size > 1) ? params.last : {}
        lock = options[:lock] || false
        defined_version = Gem::Version.new(value) if value

        UI.user_error!("Please pass minimum/required fastlane version as parameter to fastlane_version") unless defined_version
        if lock
          if Gem::Version.new(Fastlane::VERSION) != defined_version
            FastlaneCore::UpdateChecker.show_update_message('fastlane', Fastlane::VERSION)
            error_message = "The Fastfile requires a fastlane version of #{defined_version}. You are on #{Fastlane::VERSION}."
            UI.user_error!(error_message)
          end
        else
          if Gem::Version.new(Fastlane::VERSION) < defined_version
            FastlaneCore::UpdateChecker.show_update_message('fastlane', Fastlane::VERSION)
            error_message = "The Fastfile requires a fastlane version of >= #{defined_version}. You are on #{Fastlane::VERSION}."
            UI.user_error!(error_message)
          end
        end

        UI.message("Your fastlane version #{Fastlane::VERSION} matches the requirement of #{defined_version}  ✅")
      end

      def self.step_text
        "Verifying required fastlane version"
      end

      def self.authors
        ["KrauseFx", "Karthik Krishnan"]
      end

      def self.description
        "Verifies the minimum/exact fastlane version required"
      end

      def self.example_code
        ['fastlane_version "1.50.0"', 'fastlane_version "1.50.0", :lock => true']
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
