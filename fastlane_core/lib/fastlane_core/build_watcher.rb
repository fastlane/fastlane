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
          matched_build = matching_build(watched_app_version: app_version, watched_build_version: build_version, app_id: app_id, platform: platform)

          report_status(build: matched_build)

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

        if platform
          case platform.to_sym
          when :appletvos
            filter_platform = Spaceship::ConnectAPI::Platform::TV_OS
          when :osx
            filter_platform = Spaceship::ConnectAPI::Platform::MAC_OS
          else
            filter_platform = Spaceship::ConnectAPI::Platform::IOS
          end
        end

        matched_builds = Spaceship::ConnectAPI::Build.all(
          app_id: app_id,
          version: watched_app_version,
          build_number: watched_build_version,
          platform: filter_platform
        )

        if matched_builds.size > 1
          raise "FastlaneCore::BuildWatcher found more than 1 matching build"
        end

        matched_build = matched_builds.first

        return matched_build
      end

      def report_status(build: nil)
        if build && !build.processed?
          UI.message("Waiting for App Store Connect to finish processing the new build (#{build.app_version} - #{build.version}) for #{build.platform}")
        elsif build && build.processed?
          UI.success("Successfully finished processing the build #{build.app_version} - #{build.version} for #{build.platform}")
        else
          UI.message("Waiting for the build to show up in the build list - this may take a few minutes (check your email for processing issues if this continues)")
        end
      end
    end
  end
end
