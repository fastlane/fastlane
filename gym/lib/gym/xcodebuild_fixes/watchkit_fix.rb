module Gym
  class XcodebuildFixes
    class << self
      # Determine whether this app has WatchKit support and manually package up the WatchKit framework
      def watchkit_fix
        return unless should_apply_watchkit1_fix?

        UI.verbose "Adding WatchKit support"

        Dir.mktmpdir do |tmpdir|
          # Make watchkit support directory
          watchkit_support = File.join(tmpdir, "WatchKitSupport")
          Dir.mkdir(watchkit_support)

          # Copy WK from Xcode into WatchKitSupport
          FileUtils.copy_file("#{Xcode.xcode_path}/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/Library/Application Support/WatchKit/WK", File.join(watchkit_support, "WK"))

          # Add "WatchKitSupport" to the .ipa archive
          Dir.chdir(tmpdir) do
            abort unless system %(zip --recurse-paths "#{PackageCommandGenerator.ipa_path}" "WatchKitSupport" > /dev/null)
          end

          UI.verbose "Successfully added WatchKit support"
        end
      end

      # Does this application have a WatchKit target
      def watchkit?
        Dir["#{PackageCommandGenerator.appfile_path}/**/*.plist"].any? do |plist_path|
          `/usr/libexec/PlistBuddy -c 'Print WKWatchKitApp' '#{plist_path}' 2>&1`.strip == 'true'
        end
      end

      # Should only be applied if watchkit app is not a watchkit2 app
      def should_apply_watchkit1_fix?
        watchkit? && !Gym::XcodebuildFixes.watchkit2?
      end
    end
  end
end
