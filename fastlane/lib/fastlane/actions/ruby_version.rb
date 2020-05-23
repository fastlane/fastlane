module Fastlane
  module Actions
    module SharedValues
    end

    class RubyVersionAction < Action
      def self.run(params)
        params = nil unless params.kind_of?(Array)
        value = (params || []).first
        defined_version = Gem::Version.new(value) if value

        UI.user_error!("Please pass minimum ruby version as parameter to ruby_version") unless defined_version

        if Gem::Version.new(RUBY_VERSION) < defined_version
          error_message = "The Fastfile requires a ruby version of >= #{defined_version}. You are on #{RUBY_VERSION}."
          UI.user_error!(error_message)
        end

        UI.message("Your ruby version #{RUBY_VERSION} matches the minimum requirement of #{defined_version}  ✅")
      end

      def self.step_text
        "Verifying Ruby version"
      end

      def self.author
        "sebastianvarela"
      end

      def self.description
        "Verifies the minimum ruby version required"
      end

      def self.example_code
        [
          'ruby_version("2.4.0")'
        ]
      end

      def self.details
        [
          "Add this to your `Fastfile` to require a certain version of _ruby_.",
          "Put it at the top of your `Fastfile` to ensure that _fastlane_ is executed appropriately."
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
