# coding: utf-8

module Gym
  # This classes methods are called when something goes wrong in the building process
  class ErrorHandler
    class << self
      # @param [String] The output of the errored build
      # This method should raise an exception in any case, as the return code indicated a failed build
      def handle_build_error(output)
        # The order of the handling below is important
        case output
        when /Your build settings specify a provisioning profile with the UUID/
          print "Invalid code signing settings"
          print "Your project defines a provisioning profile which doesn't exist on your local machine"
          print "You can use sigh (https://github.com/fastlane/fastlane/tree/master/sigh) to download and install the provisioning profile"
          print "Follow this guide: https://docs.fastlane.tools/codesigning/GettingStarted/"
        when /Provisioning profile does not match bundle identifier/
          print "Invalid code signing settings"
          print "Your project defines a provisioning profile that doesn't match the bundle identifier of your app"
          print "Make sure you use the correct provisioning profile for this app"
          print "Take a look at the ouptput above for more information"
          print "You can follow this guide: https://docs.fastlane.tools/codesigning/GettingStarted/"
        when /provisioning profiles matching the bundle identifier .(.*)./ # the . around the (.*) are for the strange "
          print "You don't have the provisioning profile for '#{$1}' installed on the local machine"
          print "Make sure you have the profile on this computer and it's properly installed"
          print "You can use sigh (https://github.com/fastlane/fastlane/tree/master/sigh) to download and install the provisioning profile"
          print "Follow this guide: https://docs.fastlane.tools/codesigning/GettingStarted/"
        when /matching the bundle identifier .(.*). were found/ # the . around the (.*) are for the strange "
          print "You don't have a provisioning profile for the bundle identifier '#{$1}' installed on the local machine"
          print "Make sure you have the profile on this computer and it's properly installed"
          print "You can use sigh (https://github.com/fastlane/fastlane/tree/master/sigh) to download and install the provisioning profile"
          print "Follow this guide: https://docs.fastlane.tools/codesigning/GettingStarted/"

        # Insert more code signing specific errors here
        when /code signing is required/
          print "Your project settings define invalid code signing settings"
          print "To generate an ipa file you need to enable code signing for your project"
          print "Additionally make sure you have a code signing identity set"
          print "Follow this guide: https://docs.fastlane.tools/codesigning/GettingStarted/"
        when /US\-ASCII/
          print "Your shell environment is not correctly configured"
          print "Instead of UTF-8 your shell uses US-ASCII"
          print "Please add the following to your '~/.bashrc':"
          print ""
          print "       export LANG=en_US.UTF-8"
          print "       export LANGUAGE=en_US.UTF-8"
          print "       export LC_ALL=en_US.UTF-8"
          print ""
          print "You'll have to restart your shell session after updating the file."
          print "If you are using zshell or another shell, make sure to edit the correct bash file."
          print "For more information visit this stackoverflow answer:"
          print "https://stackoverflow.com/a/17031697/445598"
        end
        print_xcode_path_instructions
        print_xcode_version
        print_full_log_path
        print_build_error_instructions
        UI.build_failure!("Error building the application - see the log above", error_info: output)
      end

      # @param [Array] The output of the errored build (line by line)
      # This method should raise an exception in any case, as the return code indicated a failed build
      def handle_package_error(output)
        case output
        when /single\-bundle/
          print "Your project does not contain a single–bundle application or contains multiple products"
          print "Please read the documentation provided by Apple: https://developer.apple.com/library/ios/technotes/tn2215/_index.html"
        when /no signing identity matches '(.*)'/
          print "Could not find code signing identity '#{$1}'"
          print "Make sure the name of the code signing identity is correct"
          print "and it matches a locally installed code signing identity"
          print "You can pass the name of the code signing identity using the"
          print "`codesigning_identity` option"
        when /no provisioning profile matches '(.*)'/
          print "Could not find provisioning profile with the name '#{$1}'"
          print "Make sure the name of the provisioning profile is correct"
          print "and it matches a locally installed profile"
        when /mismatch between specified provisioning profile and signing identity/
          print "Mismatch between provisioning profile and code signing identity"
          print "This means, the specified provisioning profile was not created using"
          print "the specified certificate."
          print "Run cert and sigh before gym to make sure to have all signing resources ready"
        when /requires a provisioning profile/
          print "No provisioning profile provided"
          print "Make sure to pass a valid provisioning for each required target"
          print "Check out the docs on how to fix this: https://github.com/fastlane/fastlane/tree/master/gym#export-options"
        # insert more specific code signing errors here
        when /Codesign check fails/
          print "A general code signing error occurred. Make sure you passed a valid"
          print "provisioning profile and code signing identity."
        end
        print_full_log_path
        print_build_error_instructions
        UI.build_failure!("Error packaging up the application", error_info: output)
      end

      def handle_empty_archive
        print "The generated archive is invalid, this can have various reasons:"
        print "Usually it's caused by the `Skip Install` option in Xcode, set it to `NO`"
        print "For more information visit https://developer.apple.com/library/ios/technotes/tn2215/_index.html"
        print "Also, make sure to have a valid code signing identity and provisioning profile installed"
        print "Follow this guide to setup code signing https://docs.fastlane.tools/codesigning/GettingStarted/"
        print "If your intention was only to export an ipa be sure to provide a valid archive at the archive path."
        UI.build_failure!("Archive invalid")
      end

      private

      # Just to make things easier
      def print(text)
        UI.error text
      end

      def print_full_log_path
        return if Gym.config[:disable_xcpretty]

        log_path = Gym::BuildCommandGenerator.xcodebuild_log_path
        return unless File.exist?(log_path)

        # `xcodebuild` doesn't properly mark lines as failure reason or important information
        # so we assume that the last few lines show the error message that's relevant
        # (at least that's what was correct during testing)
        log_content = File.read(log_path).split("\n")[-5..-1]
        log_content.each do |row|
          UI.command_output(row)
        end

        UI.message("")
        UI.error("⬆️  Check out the few lines of raw `xcodebuild` output above for potential hints on how to solve this error")
        UI.important("📋  For the complete and more detailed error log, check the full log at:")
        UI.important("📋  #{log_path}")
      end

      def print_xcode_version
        # lots of the times, the user didn't set the correct Xcode version to their Xcode path
        # since many users don't look at the table of summary before running a tool, let's make
        # sure they are aware of the Xcode version and SDK they're using
        values = {
          xcode_path: File.expand_path("../..", FastlaneCore::Helper.xcode_path),
          gym_version: Fastlane::VERSION
        }

        sdk_path = Gym.project.build_settings(key: "SDKROOT")
        values[:sdk] = File.basename(sdk_path) if sdk_path.to_s.length > 0

        FastlaneCore::PrintTable.print_values(config: values,
                                           hide_keys: [],
                                               title: "Build environment".yellow)
      end

      def print_xcode_path_instructions
        xcode_path = File.expand_path("../..", FastlaneCore::Helper.xcode_path)
        default_xcode_path = "/Applications/"

        xcode_installations_in_default_path = Dir[File.join(default_xcode_path, "Xcode*.app")]
        return unless xcode_installations_in_default_path.count > 1
        UI.message ""
        UI.important "Maybe the error shown is caused by using the wrong version of Xcode"
        UI.important "Found multiple versions of Xcode in '#{default_xcode_path}'"
        UI.important "Make sure you selected the right version for your project"
        UI.important "This build process was executed using '#{xcode_path}'"
        UI.important "If you want to update your Xcode path, either"
        UI.message ""

        UI.message "- Specify the Xcode version in your Fastfile"
        UI.command_output "xcversion(version: \"8.1\") # Selects Xcode 8.1.0"
        UI.message ""

        UI.message "- Specify an absolute path to your Xcode installation in your Fastfile"
        UI.command_output "xcode_select \"/Applications/Xcode8.app\""
        UI.message ""

        UI.message "- Manually update the path using"
        UI.command_output "sudo xcode-select -s /Applications/Xcode.app"
        UI.message ""
      end

      # Indicate that code signing errors are not caused by fastlane
      # and that fastlane only runs `xcodebuild` commands
      def print_build_error_instructions
        UI.message("")
        UI.error("Looks like fastlane ran into a build/archive error with your project")
        UI.error("It's hard to tell what's causing the error, so we wrote some guides on how")
        UI.error("to troubleshoot build and signing issues: https://docs.fastlane.tools/codesigning/getting-started/")
        UI.error("Before submitting an issue on GitHub, please follow the guide above and make")
        UI.error("sure your project is set up correctly.")
        UI.error("fastlane uses `xcodebuild` commands to generate your binary, you can see the")
        UI.error("the full commands printed out in yellow in the above log.")
        UI.error("Make sure to inspect the output above, as usually you'll find more error information there")
        UI.message("")
      end
    end
  end
end
