require 'spaceship/test_flight/build'

require_relative 'ui/ui'

module FastlaneCore
  class BuildWatcher
    class << self
      # @return The build we waited for. This method will always return a build
      def wait_for_build_processing_to_be_complete(app_id: nil, platform: nil, train_version: nil, build_version: nil, poll_interval: 10, strict_build_watch: false)
        # Warn about strict_build_watch being removed in the future
        if strict_build_watch
          UI.deprecated(":strict_build_watch is no longer a used argument on FastlaneCore::BuildWatcher.")
        end

        loop do
          matched_build, build_delivery = matching_build(watched_train_version: train_version, watched_build_version: build_version, app_id: app_id, platform: platform)

          report_status(build: matched_build, build_delivery: build_delivery)

          if matched_build && matched_build.processed?
            return matched_build
          end

          sleep(poll_interval)
        end
      end

      private

      def matching_build(watched_train_version: nil, watched_build_version: nil, app_id: nil, platform: nil)
        # Get build deliveries (newly uploaded processing builds)
        client = Spaceship::ConnectAPI::Base.client
        build_deliveries = client.get_build_deliveries(filter: { app: app_id, cfBundleShortVersionString: watched_train_version, cfBundleVersion: watched_build_version }, limit: 1)
        build_delivery = build_deliveries.first

        # Get processed builds when no longer in build deliveries
        unless build_delivery
          matched_builds = Spaceship::TestFlight::Build.all(app_id: app_id, platform: platform)
          matched_build = matched_builds.find { |build| build.train_version.to_s == watched_train_version.to_s && build.build_version.to_s == watched_build_version.to_s }
        end

        return matched_build, build_delivery
      end

      def report_status(build: nil, build_delivery: nil)
        if build_delivery
          UI.message("Waiting for App Store Connect to finish processing the new build (#{build_delivery['attributes']['cfBundleShortVersionString']} - #{build_delivery['attributes']['cfBundleVersion']})")
        elsif build && !build.processed?
          UI.message("Waiting for App Store Connect to finish processing the new build (#{build.train_version} - #{build.build_version})")
        elsif build && build.processed?
          UI.success("Successfully finished processing the build #{build.train_version} - #{build.build_version}")
        else
          UI.message("Build doesn't show up in the build list anymore, waiting for it to appear again (check your email for processing issues if this continues)")
        end
      end
    end
  end
end
