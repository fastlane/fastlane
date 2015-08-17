module Gym
  class XcodebuildFixes
    class << self
      # Determine whether this app has WatchKit support and manually package up the WatchKit framework
      def watchkit_fix
        return unless watchkit?

        Helper.log.info "Adding WatchKit support" if $verbose

        Dir.mktmpdir do |tmpdir|
          # Make watchkit support directory
          watchkit_support = File.join(tmpdir, "WatchKitSupport")
          Dir.mkdir(watchkit_support)

          # Copy WK from Xcode into WatchKitSupport
          FileUtils.copy_file("#{Gym.xcode_path}/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/Library/Application Support/WatchKit/WK", File.join(watchkit_support, "WK"))

          # Add "WatchKitSupport" to the .ipa archive
          Dir.chdir(tmpdir) do
            abort unless system %(zip --recurse-paths "#{PackageCommandGenerator.ipa_path}" "WatchKitSupport" > /dev/null)
          end

          Helper.log.info "Successfully added WatchKit support" if $verbose
        end
      end

      # Does this application have a WatchKit target
      def watchkit?
        Dir["#{PackageCommandGenerator.appfile_path}/**/*.plist"].any? do |plist_path|
          `/usr/libexec/PlistBuddy -c 'Print WKWatchKitApp' '#{plist_path}' 2>&1`.strip == 'true'
        end
      end
    end
  end
end
