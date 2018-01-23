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

        def find_platform(versions, search_platform: nil)
          # We only support platforms that exist ATM
          search_platform = search_platform.to_sym if search_platform

          platform = versions.detect do |p|
            ['ios', 'osx', 'appletvos'].include?(p['platformString'])
          end

          raise "Could not find platform 'ios', 'osx' or 'appletvos'" unless platform

          # If your app has versions for both iOS and tvOS we will default to returning the iOS version for now.
          # This is intentional as we need to do more work to support apps that have hybrid versions.
          if versions.length > 1 && search_platform.nil?
            platform = versions.detect { |p| p['platformString'].to_sym == :ios }
          elsif !search_platform.nil?
            platform = versions.detect { |p| p['platformString'].to_sym == search_platform }
          end
          platform
        end
      end
    end
  end
end
