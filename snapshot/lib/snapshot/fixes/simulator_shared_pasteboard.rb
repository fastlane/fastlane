require_relative '../module'

module Snapshot
  module Fixes
    # Becoming first responder can trigger Pasteboard sync, which can stall and crash the simulator
    # See https://twitter.com/steipete/status/1227551552317140992

    class SharedPasteboardFix
      def self.patch
        UI.verbose("Patching simulator to disable Pasteboard automatic sync")

        Helper.backticks("defaults write com.apple.iphonesimulator PasteboardAutomaticSync -bool false", print: FastlaneCore::Globals.verbose?)
      end
    end
  end
end
