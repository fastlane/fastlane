module Gym
  # This classes methods are called when something goes wrong in the building process
  class ErrorHandler
    class << self
      # @param [Array] The output of the errored build (line by line)
      # This method should raise an exception in any case, as the return code indicated a failed build
      def handle_build_error(output)
        case output.join("\n")
        when /code signing is required/
          print "Your project settings don't define any code signing settings"
          print "To generate an ipa file you need to enable code signing for your project"
          print "Additionally make sure you have a code signing identity set"
          print "Follow this guide: https://github.com/KrauseFx/fastlane/blob/master/docs/CodeSigning.md"
        end
        raise "Error building the application"
      end

      # @param [Array] The output of the errored build (line by line)
      # This method should raise an exception in any case, as the return code indicated a failed build
      def handle_package_error(output)
        case output.join("\n")
        when /single\-bundle/
          print "Your project does not contain a single–bundle application or contains multiple products"
          print "Please read the documentation provided by Apple: https://developer.apple.com/library/ios/technotes/tn2215/_index.html"
        end

        raise "Error packaging up the application"
      end

      def handle_empty_archive
        print "The generated archive is invalid, this can have various reasons:"
        print "Usually it's caused by the `Skip Install` option in Xcode, set it to `NO`"
        print "For more information visit https://developer.apple.com/library/ios/technotes/tn2215/_index.html"
        raise "Archive invalid"
      end

      private

      # Just to make things easier
      def print(text)
        Helper.log.error text.red
      end
    end
  end
end
