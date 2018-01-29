require 'shellwords'

require_relative '../module'
require_relative '../generators/build_command_generator'

module Gym
  class XcodebuildFixes
    class << self
      # Determine IPAs for the Watch App which aren't inside of a containing
      # iOS App and removes them.
      #
      # In the future it may be nice to modify the plist file for the archive
      # itself so that it points to the correct IPA as well.
      #
      # This is a workaround for this bug
      # https://github.com/CocoaPods/CocoaPods/issues/4178
      def generic_archive_fix
        UI.verbose("Looking For Orphaned WatchKit2 Applications")

        Dir.glob("#{BuildCommandGenerator.archive_path}/Products/Applications/*.app").each do |app_path|
          if is_watchkit_app?(app_path)
            UI.verbose("Removing Orphaned WatchKit2 Application #{app_path}")
            FileUtils.rm_rf(app_path)
          end
        end
      end

      # Does this application have a WatchKit target
      def is_watchkit_app?(app_path)
        plist_path = "#{app_path}/Info.plist"
        `/usr/libexec/PlistBuddy -c 'Print :DTSDKName' #{plist_path.shellescape} 2>&1`.match(/^\s*watchos2\.\d+\s*$/) != nil
      end
    end
  end
end
