require 'spaceship/connect_api'

require_relative 'ui/ui'

module FastlaneCore
  class BuildWatcher
    class << self
      # @return The build we waited for. This method will always return a build
      def wait_for_build_processing_to_be_complete(app_id: nil, platform: nil, train_version: nil, app_version: nil, build_version: nil, poll_interval: 10, strict_build_watch: false, return_spaceship_testflight_build: true)
        # Warn about train_version being removed in the future
        if train_version
          UI.deprecated(":train_version is no longer a used argument on FastlaneCore::BuildWatcher. Please use :app_version instead.")
        end
        app_version = train_version

        # Warn about strict_build_watch being removed in the future
        if strict_build_watch
          UI.deprecated(":strict_build_watch is no longer a used argument on FastlaneCore::BuildWatcher.")
        end

        loop do
          matched_build, build_delivery = matching_build(watched_app_version: app_version, watched_build_version: build_version, app_id: app_id)

          report_status(build: matched_build, build_delivery: build_delivery)

          if matched_build && matched_build.processed?
            if return_spaceship_testflight_build
              return matched_build.to_testflight_build
            else
              return matched_build
            end
          end

          sleep(poll_interval)
        end
      end

      private

      # Remove leading zeros ( https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html#//apple_ref/doc/uid/20001431-102364 )
      def remove_version_leading_zeros(version: nil)
        return version.instance_of?(String) ? version.split('.').map { |s| s.to_i.to_s }.join('.') : version
      end

      def matching_build(watched_app_version: nil, watched_build_version: nil, app_id: nil, platform: nil)
        # Get build deliveries (newly uploaded processing builds)
        watched_app_version = remove_version_leading_zeros(version: watched_app_version)
        watched_build_version = remove_version_leading_zeros(version: watched_build_version)

        build_deliveries = Spaceship::ConnectAPI::BuildDelivery.all(app_id: app_id, version: watched_app_version, build_number: watched_build_version)
        build_delivery = build_deliveries.first

        # Get processed builds when no longer in build deliveries
        if build_delivery.nil?
          matched_builds = Spaceship::ConnectAPI::Build.all(
            app_id: app_id,
            version: watched_app_version,
            build_number: watched_build_version,
            includes: "app,preReleaseVersion"
          )
          matched_build = matched_builds.first
        end

        return matched_build, build_delivery
      end

      def report_status(build: nil, build_delivery: nil)
        if build_delivery
          UI.message("Waiting for App Store Connect to finish processing the new build (#{build_delivery.cf_build_short_version_string} - #{build_delivery.cf_build_version})")
        elsif build && !build.processed?
          UI.message("Waiting for App Store Connect to finish processing the new build (#{build.app_version} - #{build.version})")
        elsif build && build.processed?
          UI.success("Successfully finished processing the build #{build.app_version} - #{build.version}")
        else
          UI.message("Build doesn't show up in the build list anymore, waiting for it to appear again (check your email for processing issues if this continues)")
        end
      end
    end
  end
end
