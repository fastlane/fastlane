require 'spaceship/connect_api'

require_relative 'ui/ui'

module FastlaneCore
  class BuildWatcherError < StandardError
  end

  class BuildWatcher
    VersionMatches = Struct.new(:version, :builds)

    class << self
      # @return The build we waited for. This method will always return a build
      def wait_for_build_processing_to_be_complete(app_id: nil, platform: nil, train_version: nil, app_version: nil, build_version: nil, poll_interval: 10, timeout_duration: nil, strict_build_watch: false, return_when_build_appears: false, return_spaceship_testflight_build: true, select_latest: false, wait_for_build_beta_detail_processing: false)
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

        build_watching_start_time = Time.new
        unless timeout_duration.nil?
          end_time = build_watching_start_time + timeout_duration
          UI.message("Will timeout watching build after #{timeout_duration} seconds around #{end_time}...")
        end

        showed_info = false
        loop do
          matched_build, app_version_queried = matching_build(watched_app_version: app_version, watched_build_version: build_version, app_id: app_id, platform: platform, select_latest: select_latest)

          if matched_build.nil? && !showed_info
            UI.important("Read more information on why this build isn't showing up yet - https://github.com/fastlane/fastlane/issues/14997")
            showed_info = true
          end

          report_status(build: matched_build, wait_for_build_beta_detail_processing: wait_for_build_beta_detail_processing)

          # Processing of builds by AppStoreConnect can be a very time consuming task and will
          # block the worker running this task until it is completed. In some cases,
          # having a build resource appear in AppStoreConnect (matched_build) may be enough (i.e. setting a changelog)
          # so here we may choose to skip the full processing of the build if return_when_build_appears is true
          if matched_build && (return_when_build_appears || processed?(build: matched_build, wait_for_build_beta_detail_processing: wait_for_build_beta_detail_processing))

            if !app_version.nil? && app_version != app_version_queried
              UI.important("App version is #{app_version} but build was found while querying #{app_version_queried}")
              UI.important("This shouldn't be an issue as Apple sees #{app_version} and #{app_version_queried} as equal")
              UI.important("See docs for more info - https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html#//apple_ref/doc/uid/20001431-102364")
            end

            if return_spaceship_testflight_build
              return matched_build.to_testflight_build
            else
              return matched_build
            end
          end

          # Before next poll, force stop build watching, if we exceeded the 'timeout_duration' waiting time
          force_stop_build_watching_if_required(start_time: build_watching_start_time, timeout_duration: timeout_duration)

          sleep(poll_interval)
        end
      end

      private

      # Remove leading zeros ( https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html#//apple_ref/doc/uid/20001431-102364 )
      def remove_version_leading_zeros(version: nil)
        return version.instance_of?(String) ? version.split('.').map { |s| s.to_i.to_s }.join('.') : version
      end

      def matching_build(watched_app_version: nil, watched_build_version: nil, app_id: nil, platform: nil, select_latest: false)
        # Get build deliveries (newly uploaded processing builds)
        watched_app_version = remove_version_leading_zeros(version: watched_app_version)
        watched_build_version = remove_version_leading_zeros(version: watched_build_version)

        # App Store Connect will allow users to upload  X.Y is the same as X.Y.0 and treat them as the same version
        # However, only the first uploaded version format will be the one that is queryable
        # This could lead to BuildWatcher never finding X.Y.0 if X.Y was uploaded first as X.Y will only yield results
        #
        # This will add an additional request to search for both X.Y and X.Y.0 but
        # will give preference to the version format specified passed in
        watched_app_version_alternate = alternate_version(watched_app_version)
        versions = [watched_app_version, watched_app_version_alternate].compact

        if versions.empty?
          if select_latest
            message = watched_build_version.nil? ? "Searching for the latest build" : "Searching for the latest build with build number: #{watched_build_version}"
            UI.message(message)
            versions = [nil]
          else
            raise BuildWatcherError.new, "There is no app version to watch"
          end
        end

        version_matches = versions.map do |version|
          match = VersionMatches.new
          match.version = version
          match.builds = Spaceship::ConnectAPI::Build.all(
            app_id: app_id,
            version: version,
            build_number: watched_build_version,
            platform: platform
          )

          match
        end.flatten

        # Raise error if more than 1 build is returned
        # This should never happen but need to inform the user if it does
        matched_builds = version_matches.map(&:builds).flatten

        # Need to filter out duplicate builds (which could be a result from the double X.Y.0 and X.Y queries)
        # See: https://github.com/fastlane/fastlane/issues/22248
        matched_builds = matched_builds.uniq(&:id)

        if matched_builds.size > 1 && !select_latest
          error_builds = matched_builds.map do |build|
            "#{build.app_version}(#{build.version}) for #{build.platform} - #{build.processing_state}"
          end.join("\n")
          error_message = "Found more than 1 matching build: \n#{error_builds}"
          raise BuildWatcherError.new, error_message
        end

        version_match = version_matches.reject do |match|
          match.builds.empty?
        end.first
        matched_build = version_match&.builds&.first

        return matched_build, version_match&.version
      end

      def alternate_version(version)
        return nil if version.nil?

        version_info = Gem::Version.new(version)
        if version_info.segments.size == 3 && version_info.segments[2] == 0
          return version_info.segments[0..1].join(".")
        elsif version_info.segments.size == 2
          return "#{version}.0"
        end

        return nil
      end

      def processed?(build: nil, wait_for_build_beta_detail_processing: false)
        return false unless build

        is_processed = build.processed?

        # App Store Connect API has multiple build processing states
        # builds have one processing status
        # buildBetaDetails have two processing statues (internal and external testing)
        #
        # If set, this method will only return true if all three statuses are complete
        if wait_for_build_beta_detail_processing
          is_processed &&= (build.build_beta_detail&.processed? || false)
        end

        return is_processed
      end

      def report_status(build: nil, wait_for_build_beta_detail_processing: false)
        is_processed = processed?(build: build, wait_for_build_beta_detail_processing: wait_for_build_beta_detail_processing)

        if build && !is_processed
          UI.message("Waiting for App Store Connect to finish processing the new build (#{build.app_version} - #{build.version}) for #{build.platform}")
        elsif build && is_processed
          UI.success("Successfully finished processing the build #{build.app_version} - #{build.version} for #{build.platform}")
        else
          UI.message("Waiting for the build to show up in the build list - this may take a few minutes (check your email for processing issues if this continues)")
        end
      end

      def force_stop_build_watching_if_required(start_time: nil, timeout_duration: nil)
        return if start_time.nil? || timeout_duration.nil? # keep watching build for App Store Connect processing

        current_time = Time.new
        end_time = start_time + timeout_duration
        pending_duration = end_time - current_time

        if current_time > end_time
          UI.crash!("FastlaneCore::BuildWatcher exceeded the '#{timeout_duration.to_i}' seconds, Stopping now!")
        else
          UI.verbose("Will timeout watching build after pending #{pending_duration.to_i} seconds around #{end_time}...")
        end
      end
    end
  end
end
