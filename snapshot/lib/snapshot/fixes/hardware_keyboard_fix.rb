require_relative '../module'

module Snapshot
  module Fixes
    # Having "Connect Hardware Keyboard" enabled causes issues with entering text in secure textfields
    # Fixes https://github.com/fastlane/fastlane/issues/2494

    class HardwareKeyboardFix
      def self.patch
        UI.verbose("Patching simulator to work with secure text fields")

        Helper.backticks("defaults write com.apple.iphonesimulator ConnectHardwareKeyboard 0", print: FastlaneCore::Globals.verbose?)

        # For > Xcode 9
        # https://stackoverflow.com/questions/38010494/is-it-possible-to-toggle-software-keyboard-via-the-code-in-ui-test/47820883#47820883
        Helper.backticks("/usr/libexec/PlistBuddy "\
                         "-c \"Print :DevicePreferences\" ~/Library/Preferences/com.apple.iphonesimulator.plist | "\
                         "perl -lne 'print $1 if /^    (\\S*) =/' | while read -r a; do /usr/libexec/PlistBuddy "\
                         "-c \"Set :DevicePreferences:$a:ConnectHardwareKeyboard false\" "\
                         "~/Library/Preferences/com.apple.iphonesimulator.plist "\
                         "|| /usr/libexec/PlistBuddy "\
                         "-c \"Add :DevicePreferences:$a:ConnectHardwareKeyboard bool false\" "\
                         "~/Library/Preferences/com.apple.iphonesimulator.plist; done", print: FastlaneCore::Globals.verbose?)
      end
    end
  end
end
