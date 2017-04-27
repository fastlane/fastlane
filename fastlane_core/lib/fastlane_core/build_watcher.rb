module FastlaneCore
  class BuildWatcher
    # @return The build we waited for. This method will always return a build
    def self.wait_for_build_processing_to_be_complete(app_id: nil, platform: nil)
      # First, find the train and build version we want to watch for
      watching_build = watching_build(app_id: app_id, platform: platform)

      loop do
        UI.message("Waiting for iTunes Connect to finish processing the new build (#{watching_build.train_version} - #{watching_build.build_version})")

        # Due to iTunes Connect, builds disappear from the build list alltogether
        # after they finished processing. Before returning this build, we have to
        # wait for the build to appear in the build list again
        # As this method is very often used to wait for a build, and then do something
        # with it, we have to be sure that the build actually is ready

        matching_builds = Spaceship::TestFlight::Build.builds_for_train(app_id: app_id, platform: platform, train_version: watching_build.train_version)
        matching_build = matching_builds.find { |build| build.build_version == watching_build.build_version }

        report_status(matching_build)

        return matching_build if processing_complete?(matching_build)

        sleep 10
      end
    end

    private

    def self.matching_build(watching_build: nil, app_id: nil, platform: nil)
    end

    def self.report_status(build: nil)
      if matching_build.nil?
        UI.message("Build doesn't show up in the build list any more, waiting for it to appear again")
      elsif matching_build.active?
        UI.success("Build #{matching_build.train_version} - #{matching_build.build_version} is already being tested")
      elsif matching_build.ready_to_submit? || matching_build.export_compliance_missing?
        UI.success("Successfully finished processing the build #{matching_build.train_version} - #{matching_build.build_version}")
      end      
    end

    def self.processing_complete?(build: nil)
      matching_build.active? || matching_build.ready_to_submit? || matching_build.export_compliance_missing?
    end

    def self.watching_build(app_id: nil, platform: nil)
      processing_builds = Spaceship::TestFlight::Build.all_processing_builds(app_id: app_id, platform: platform)

      watching_build = processing_builds.sort_by(&:upload_date).last
      watching_build ||= Spaceship::TestFlight::Build.latest(app_id: app_id, platform: platform)      
    end
  end
end
