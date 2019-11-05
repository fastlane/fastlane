require 'shellwords'

module Fastlane
  module Actions
    module SharedValues
    end

    class VerifyXcodeAction < Action
      def self.run(params)
        UI.message("Verifying your Xcode installation at path '#{params[:xcode_path]}'...")

        # Check 1/2
        verify_codesign(params)

        # Check 2/2
        # More information https://developer.apple.com/news/?id=09222015a
        verify_gatekeeper(params)

        true
      end

      def self.verify_codesign(params)
        UI.message("Verifying Xcode was signed by Apple Inc.")

        codesign_output = Actions.sh("codesign --display --verbose=4 #{params[:xcode_path].shellescape}")

        # If the returned codesign info contains all entries for any one of these sets, we'll consider it valid
        accepted_codesign_detail_sets = [
          [ # Found on App Store installed Xcode installations
            "Identifier=com.apple.dt.Xcode",
            "Authority=Apple Mac OS Application Signing",
            "Authority=Apple Worldwide Developer Relations Certification Authority",
            "Authority=Apple Root CA",
            "TeamIdentifier=59GAB85EFG"
          ],
          [ # Found on Xcode installations (pre-Xcode 8) downloaded from developer.apple.com
            "Identifier=com.apple.dt.Xcode",
            "Authority=Software Signing",
            "Authority=Apple Code Signing Certification Authority",
            "Authority=Apple Root CA",
            "TeamIdentifier=not set"
          ],
          [ # Found on Xcode installations (post-Xcode 8) downloaded from developer.apple.com
            "Identifier=com.apple.dt.Xcode",
            "Authority=Software Signing",
            "Authority=Apple Code Signing Certification Authority",
            "Authority=Apple Root CA",
            "TeamIdentifier=59GAB85EFG"
          ]
        ]

        # Map the accepted details sets into an equal number of sets collecting the details for which
        # the output of codesign did not have matches
        missing_details_sets = accepted_codesign_detail_sets.map do |accepted_details_set|
          accepted_details_set.reject { |detail| codesign_output.include?(detail) }
        end

        # If any of the sets is empty, it means that all details were matched, and the check is successful
        show_and_raise_error(nil, params[:xcode_path]) unless missing_details_sets.any?(&:empty?)

        UI.success("Successfully verified the code signature ✅")
      end

      def self.verify_gatekeeper(params)
        UI.message("Verifying Xcode using GateKeeper...")
        UI.message("This will take up to a few minutes, now is a great time to go for a coffee ☕...")

        command = "/usr/sbin/spctl --assess --verbose #{params[:xcode_path].shellescape}"
        must_includes = ['accepted']

        output = verify(command: command, must_includes: must_includes, params: params)

        if output.include?("source=Mac App Store") || output.include?("source=Apple") || output.include?("source=Apple System")
          UI.success("Successfully verified Xcode installation at path '#{params[:xcode_path]}' 🎧")
        else
          show_and_raise_error("Invalid Download Source of Xcode: #{output}", params[:xcode_path])
        end
      end

      def self.verify(command: nil, must_includes: nil, params: nil)
        output = Actions.sh(command)

        errors = []
        must_includes.each do |current|
          next if output.include?(current)
          errors << current
        end

        if errors.count > 0
          show_and_raise_error(errors.join("\n"), params[:xcode_path])
        end

        return output
      end

      def self.show_and_raise_error(error, xcode_path)
        UI.error("Attention: Your Xcode Installation could not be verified.")
        UI.error("If you believe that your Xcode is valid, please submit an issue on GitHub")
        if error
          UI.error("The following information couldn't be found:")
          UI.error(error)
        end
        UI.user_error!("The Xcode installation at path '#{xcode_path}' could not be verified.")
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Verifies that the Xcode installation is properly signed by Apple"
      end

      def self.details
        "This action was implemented after the recent Xcode attack to make sure you're not using a [hacked Xcode installation](http://researchcenter.paloaltonetworks.com/2015/09/novel-malware-xcodeghost-modifies-xcode-infects-apple-ios-apps-and-hits-app-store/)."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :xcode_path,
                                       env_name: "FL_VERIFY_XCODE_XCODE_PATH",
                                       description: "The path to the Xcode installation to test",
                                       code_gen_sensitive: true,
                                       default_value: File.expand_path('../../', FastlaneCore::Helper.xcode_path),
                                       default_value_dynamic: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find Xcode at path '#{value}'") unless File.exist?(value)
                                       end)
        ]
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'verify_xcode',
          'verify_xcode(xcode_path: "/Applications/Xcode.app")'
        ]
      end

      def self.category
        :building
      end
    end
  end
end
