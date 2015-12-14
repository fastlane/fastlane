module Fastlane
  module Actions
    module SharedValues
    end

    class VerifyXcodeAction < Action
      def self.run(params)
        Helper.log.info "Verifying your Xcode installation at path '#{params[:xcode_path]}'...".green

        # Check 1/2

        Helper.log.info "Verifying Xcode was signed by Apple Inc.".green
        command = "codesign --display --verbose=4 '#{params[:xcode_path]}'"

        must_includes = [
          "Identifier=com.apple.dt.Xcode",
          "Authority=Apple Mac OS Application Signing",
          "Authority=Apple Worldwide Developer Relations Certification Authority",
          "Authority=Apple Root CA",
          "TeamIdentifier=59GAB85EFG"
        ]

        verify(command: command, must_includes: must_includes, params: params)

        Helper.log.info "Successfully verified the code signature".green

        # Check 2/2
        # More information https://developer.apple.com/news/?id=09222015a
        Helper.log.info "Verifying Xcode using GateKeeper..."
        Helper.log.info "This will take up to a few minutes, now is a great time to go for a coffee ☕...".green

        command = "/usr/sbin/spctl --assess --verbose '#{params[:xcode_path]}'"
        must_includes = ['accepted']

        output = verify(command: command, must_includes: must_includes, params: params)

        if output.include?("source=Mac App Store") or output.include?("source=Apple") or output.include?("source=Apple System")
          Helper.log.info "Successfully verified Xcode installation at path '#{params[:xcode_path]}' 🎧".green
        else
          show_and_raise_error("Invalid Download Source of Xcode: #{output}")
        end

        true
      end

      def self.verify(command: nil, must_includes: nil, params: nil)
        output = Actions.sh(command)

        errors = []
        must_includes.each do |current|
          next if output.include?(current)
          errors << current
        end

        if errors.count > 0
          show_and_raise_error(errors.join("\n"))
        end

        return output
      end

      def self.show_and_raise_error(error)
        Helper.log.fatal "Attention: Your Xcode Installation might be hacked.".red
        Helper.log.fatal "This might be a false alarm, if so, please submit an issue on GitHub".red
        Helper.log.fatal "The following information couldn't be found:".red
        Helper.log.fatal error.yellow
        raise "The Xcode installation at path '#{params[:xcode_path]}' might be compromised."
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Verifies that the Xcode installation is properly signed by Apple"
      end

      def self.details
        [
          "This action was implemented after the recent Xcode attacked to make sure",
          "you're not using a hacked Xcode installation.",
          "http://researchcenter.paloaltonetworks.com/2015/09/novel-malware-xcodeghost-modifies-xcode-infects-apple-ios-apps-and-hits-app-store/"
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :xcode_path,
                                       env_name: "FL_VERIFY_XCODE_XCODE_PATH",
                                       description: "The path to the Xcode installation to test",
                                       default_value: File.expand_path('../../', FastlaneCore::Helper.xcode_path),
                                       verify_block: proc do |value|
                                         raise "Couldn't find Xcode at path '#{value}'".red unless File.exist?(value)
                                       end)
        ]
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
