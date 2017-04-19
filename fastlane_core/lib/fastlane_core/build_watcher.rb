module FastlaneCore
  class BuildWatcher
    # @return The build we waited for. This method will always return a build
    def self.wait_for_build_processing_to_be_complete(provider_id, app_id, platform: nil)
      # First, find the train and build version we want to watch for
      processing_builds = TestFlight::Build.all_processing_builds(provider_id: provider_id, app_id: app_id, platform: platform)

      watching_build = processing_builds.sort_by(&:upload_date).last # either it's still processing
      watching_build ||= TestFlight::Build.latest(provider_id: Spaceship::Application.client.team_id, app_id: app_id, platform: platform) # or we fallback to the most recent uplaod

      loop do
        UI.message("Waiting for iTunes Connect to finish processing the new build (#{watching_build.train_version} - #{watching_build.build_version})")

        # Due to iTunes Connect, builds disappear from the build list alltogether
        # after they finished processing. Before returning this build, we have to
        # wait for the build to appear in the build list again
        # As this method is very often used to wait for a build, and then do something
        # with it, we have to be sure that the build actually is ready
        all_builds = TestFlight::Build.all_builds(provider_id: provider_id, app_id: app_id, platform: platform)
        matching_build = all_builds.find { |b| b.train_version == watching_build.train_version && b.build_version == watching_build.build_version }

        if matching_build.nil?
          UI.message("Build doesn't show up in the build list any more, waiting for it to appear again")
        elsif matching_build.ready_to_submit?          
          UI.success("Successfully finished processing the build #{matching_build.train_version} - #{matching_build.build_version}")
          return matching_build
        end

        sleep 3
      end
    end
  end
end
