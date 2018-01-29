require_relative '../module'

module Snapshot
  module Fixes
    # Having "Connect Hardware Keyboard" enabled causes issues with entering text in secure textfields
    # Fixes https://github.com/fastlane/fastlane/issues/2494

    class HardwareKeyboardFix
      def self.patch
        UI.verbose("Patching simulator to work with secure text fields")

        Helper.backticks("defaults write com.apple.iphonesimulator ConnectHardwareKeyboard 0", print: FastlaneCore::Globals.verbose?)
      end
    end
  end
end
