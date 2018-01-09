require 'spaceship/test_flight/build'

require_relative 'ui/ui'

module FastlaneCore
  class BuildWatcher
    class << self
      # @return The build we waited for. This method will always return a build
      def wait_for_build_processing_to_be_complete(app_id: nil, platform: nil, train_version: nil, build_version: nil, poll_interval: 10, strict_build_watch: false)
        unless strict_build_watch
          # First, find the train and build version we want to watch for
          watched_build = watching_build(app_id: app_id, platform: platform)
          UI.crash!("Could not find a build for app: #{app_id} on platform: #{platform}") if watched_build.nil?

          unless watched_build.train_version == train_version && watched_build.build_version == build_version
            UI.important("Started watching build #{watched_build.train_version} - #{watched_build.build_version} but expected #{train_version} - #{build_version}")
          end
          train_version = watched_build.train_version
          build_version = watched_build.build_version
        end

        loop do
          matched_build = matching_build(watched_train_version: train_version, watched_build_version: build_version, app_id: app_id, platform: platform)

          report_status(build: matched_build)

          if matched_build && matched_build.processed?
            return matched_build
          end

          sleep(poll_interval)
        end
      end

      private

      def watching_build(app_id: nil, platform: nil)
        processing_builds = Spaceship::TestFlight::Build.all_processing_builds(app_id: app_id, platform: platform, retry_count: 2)

        watched_build = processing_builds.sort_by(&:upload_date).last
        watched_build || Spaceship::TestFlight::Build.latest(app_id: app_id, platform: platform)
      end

      def matching_build(watched_train_version: nil, watched_build_version: nil, app_id: nil, platform: nil)
        matched_builds = Spaceship::TestFlight::Build.builds_for_train(app_id: app_id, platform: platform, train_version: watched_train_version, retry_count: 2)
        matched_builds.find { |build| build.build_version == watched_build_version }
      end

      def report_status(build: nil)
        # Due to iTunes Connect, builds disappear from the build list altogether
        # after they finished processing. Before returning this build, we have to
        # wait for the build to appear in the build list again
        # As this method is very often used to wait for a build, and then do something
        # with it, we have to be sure that the build actually is ready
        if build.nil?
          UI.message("Build doesn't show up in the build list anymore, waiting for it to appear again")
        elsif build.active?
          UI.success("Build #{build.train_version} - #{build.build_version} is already being tested")
        elsif build.ready_to_submit? || build.export_compliance_missing? || build.review_rejected?
          UI.success("Successfully finished processing the build #{build.train_version} - #{build.build_version}")
        else
          UI.message("Waiting for iTunes Connect to finish processing the new build (#{build.train_version} - #{build.build_version})")
        end
      end
    end
  end
end
