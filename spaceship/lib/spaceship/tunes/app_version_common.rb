module Spaceship
  module Tunes
    # internal to spaceship
    # Represents the common structure between application['versionSets'] and app_version['platform']
    class AppVersionCommon
      class << self
        def find_version_id(platform, is_live)
          version = platform[(is_live ? 'deliverableVersion' : 'inFlightVersion')]
          return nil unless version
          version['id']
        end

        def find_platform(versions)
          # We only support platforms that exist ATM
          platform = versions.detect do |p|
            ['ios', 'osx', 'appletvos'].include? p['platformString']
          end

          raise "Could not find platform ios, osx or appletvos for app #{app_id}" unless platform

          # If your app has versions for both iOS and tvOS we will default to returning the iOS version for now.
          # This is intentional as we need to do more work to support apps that have hybrid versions.
          if versions.length > 1
            platform = versions.detect { |p| p['platformString'] == "ios" }
          end
          platform
        end
      end
    end
  end
end
