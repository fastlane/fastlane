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
        print_full_log_path
        UI.user_error!("Error building the application - see the log above")
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
        # insert more specific code signing errors here
        when /Codesign check fails/
          print "A general code signing error occurred. Make sure you passed a valid"
          print "provisioning profile and code signing identity."
        when /expected one of \{\}/
          print "It seems like you ran into this radar"
          print "https://openradar.appspot.com/radar?id=4952000420642816"
          print "You can temporary use the :use_legacy_build_api option to get the build to work again"
        when /IDEDistributionErrorDomain error 1/
        when /Error Domain=IDEDistributionErrorDomain Code=/
          standard_output = read_standard_output output
          print standard_output if standard_output
          print "There was an error exporting your application"
          print "Unfortunately the new Xcode export API is unstable and causes problems on some projects"
          print "You can temporary use the :use_legacy_build_api option to get the build to work again"
        end
        print_full_log_path
        UI.user_error!("Error packaging up the application")
      end

      def handle_empty_archive
        print "The generated archive is invalid, this can have various reasons:"
        print "Usually it's caused by the `Skip Install` option in Xcode, set it to `NO`"
        print "For more information visit https://developer.apple.com/library/ios/technotes/tn2215/_index.html"
        print "Also, make sure to have a valid code signing identity and provisioning profile installed"
        print "Follow this guide to setup code signing https://docs.fastlane.tools/codesigning/GettingStarted/"
        print "If your intention was only to export an ipa be sure to provide a valid archive at the archive path."
        UI.user_error!("Archive invalid")
      end

      def find_standard_output_path(output)
        m = /Created bundle at path '(.*)'/.match(output)
        return File.join(m[1], 'IDEDistribution.standard.log') unless m.nil?
      end

      private

      def read_standard_output(output)
        path = find_standard_output_path output
        return File.read(path) if File.exist?(path)
      end

      # Just to make things easier
      def print(text)
        UI.error text
      end

      def print_full_log_path
        return if Gym.config[:disable_xcpretty]
        log_path = Gym::BuildCommandGenerator.xcodebuild_log_path
        UI.error("📋  For a more detailed error log, check the full log at:")
        UI.error("📋  #{log_path}")
      end
    end
  end
end
