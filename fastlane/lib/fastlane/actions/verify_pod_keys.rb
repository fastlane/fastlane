module Fastlane
  module Actions
    class VerifyPodKeysAction < Action
      def self.run(params)
        UI.message("Validating CocoaPods Keys")

        options = plugin_options
        target = options["target"] || ""

        options["keys"].each do |key|
          UI.message(" - #{key}")
          validate(key, target)
        end
      end

      def self.plugin_options
        require 'cocoapods-core'
        podfile = Pod::Podfile.from_file("Podfile")
        podfile.plugins["cocoapods-keys"]
      end

      def self.validate(key, target)
        if value(key, target).length < 2
          message = "Did not pass validation for key #{key}. " \
            "Run `[bundle exec] pod keys get #{key} #{target}` to see what it is. " \
            "It's likely this is running with empty/OSS keys."
          raise message
        end
      end

      def self.value(key, target)
        command = ["pod", "keys", "get", key]
        command << target unless target.to_s.empty?
        # Not Actions.sh: it adds stderr to the value, and --troubleshoot would print the secret
        require 'open3'
        value, error, status = Open3.capture3(*command)
        UI.user_error!("`#{command.shelljoin}` failed: #{error.strip}") unless status.success?
        value.split("]").last.to_s.strip
      end

      def self.author
        "ashfurrow"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Verifies all keys referenced from the Podfile are non-empty"
      end

      def self.details
        "Runs a check against all keys specified in your Podfile to make sure they're more than a single character long. This is to ensure you don't deploy with stubbed keys."
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'verify_pod_keys'
        ]
      end

      def self.category
        :building
      end
    end
  end
end
