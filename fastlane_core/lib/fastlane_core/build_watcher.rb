require 'spaceship/connect_api'

require_relative 'ui/ui'

module FastlaneCore
  class BuildWatcher
    class << self
      # @return The build we waited for. This method will always return a build
      def wait_for_build_processing_to_be_complete(app_id: nil, platform: nil, train_version: nil, app_version: nil, build_version: nil, poll_interval: 10, strict_build_watch: false, return_when_build_appears: false, return_spaceship_testflight_build: true)
        # Warn about train_version being removed in the future
        if train_version
          UI.deprecated(":train_version is no longer a used argument on FastlaneCore::BuildWatcher. Please use :app_version instead.")
          app_version = train_version
        end

        # Warn about strict_build_watch being removed in the future
        if strict_build_watch
          UI.deprecated(":strict_build_watch is no longer a used argument on FastlaneCore::BuildWatcher.")
        end

        platform = Spaceship::ConnectAPI::Platform.map(platform) if platform
        UI.message("Waiting for processing on... app_id: #{app_id}, app_version: #{app_version}, build_version: #{build_version}, platform: #{platform}")

        showed_info = false
        loop do
          matched_build = matching_build(watched_app_version: app_version, watched_build_version: build_version, app_id: app_id, platform: platform)

          if matched_build.nil? && !showed_info
            UI.important("Read more information on why this build isn't showing up yet - https://github.com/fastlane/fastlane/issues/14997")
            showed_info = true
          end

          report_status(build: matched_build)

          # Processing of builds by AppStoreConnect can be a very time consuming task and will
          # block the worker running this task until it is completed. In some cases,
          # having a build resource appear in AppStoreConnect (matched_build) may be enough (i.e. setting a changelog)
          # so here we may choose to skip the full processing of the build if return_when_build_appears is true
          if matched_build && (return_when_build_appears || matched_build.processed?)
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

        matched_builds = Spaceship::ConnectAPI::Build.all(
          app_id: app_id,
          version: watched_app_version,
          build_number: watched_build_version,
          platform: platform
        )

        # Raise error if more than 1 build is returned
        # This should never happen but need to inform the user if it does
        if matched_builds.size > 1
          error_builds = matched_builds.map do |build|
            "#{build.app_version}(#{build.version}) for #{build.platform} - #{build.processing_state}"
          end.join("\n")
          error_message = "FastlaneCore::BuildWatcher found more than 1 matching build: \n#{error_builds}"
          UI.crash!(error_message)
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
