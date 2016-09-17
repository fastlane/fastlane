module Gym
  class XcodebuildFixes
    class << self
      # Determine whether this app has WatchKit2 support and manually package up the WatchKit2 framework
      def watchkit2_fix
        return unless watchkit2?

        UI.verbose "Adding WatchKit2 support"

        Dir.mktmpdir do |tmpdir|
          # Make watchkit support directory
          watchkit_support = File.join(tmpdir, "WatchKitSupport2")
          Dir.mkdir(watchkit_support)

          # Copy WK from Xcode into WatchKitSupport2
          FileUtils.copy_file("#{Xcode.xcode_path}/Platforms/WatchOS.platform/Developer/SDKs/WatchOS.sdk/Library/Application Support/WatchKit/WK", File.join(watchkit_support, "WK"))

          # Add "WatchKitSupport2" to the .ipa archive
          Dir.chdir(tmpdir) do
            abort unless system %(zip --recurse-paths "#{PackageCommandGenerator.ipa_path}" "WatchKitSupport2" > /dev/null)
          end

          UI.verbose "Successfully added WatchKit2 support"
        end
      end

      # Does this application have a WatchKit target
      def watchkit2?
        Dir["#{PackageCommandGenerator.appfile_path}/**/*.plist"].any? do |plist_path|
          `/usr/libexec/PlistBuddy -c 'Print DTSDKName' '#{plist_path}' 2>&1`.match(/^\s*watchos2\.\d+\s*$/)
        end
      end
    end
  end
end
