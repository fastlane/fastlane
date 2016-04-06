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
        UI.verbose "Removing Orphaned WatchKit2 Applications"

        Dir.glob("#{BuildCommandGenerator.archive_path}/Products/Applications/*.app").each do |app_path|
          if is_watchkit_ipa?("#{app_path}/info.plist")
            FileUtils.rm_rf(app_path)
            UI.verbose "Removed #{app_path}"
          end
        end
      end

      # Does this application have a WatchKit target
      def is_watchkit_ipa?(plist_path)
        `/usr/libexec/PlistBuddy -c 'Print DTSDKName' '#{plist_path}' 2>&1`.match(/^\s*watchos2\.\d+\s*$/) != nil
      end
    end
  end
end
