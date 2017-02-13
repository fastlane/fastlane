module FastlaneCore
  class BuildWatcher
    def self.find_build(app = nil)
      build = nil
      app.latest_version.candidate_builds.each do |b|
        if !build or b.upload_date > build.upload_date
          build = b
        end
      end
      unless build
        UI.user_error!("No processing builds available for app #{app.bundle_id}")
      end
      return build
    end

    def self.wait_for_train(app = nil, platform = "ios", sleep_time = 30)
      loop do
        sleep(sleep_time)
        if app.build_trains(platform: platform).count == 0
          UI.message("New application; waiting for build train to appear on iTunes Connect")
        else
          break
        end
      end
    end

    def self.wait_for_build(app = nil, platform = "ios", sleep_time = 0)
      start_time = Time.now
      UI.user_error!("Could not find app with app identifier #{app.bundle_id}") unless app
      # if this is a new version/app wait for train to show up.
      if app.build_trains(platform: platform).count == 0
        self.class.wait_for_train(app, platform, sleep_time)
      end

      latest_build = nil
      loop do
        if sleep_time > 0
          sleep(sleep_time)
        else
          return nil
        end
        builds = app.all_processing_builds(platform: platform)
        break if builds.count == 0
        latest_build = builds.last
        UI.message("Waiting for iTunes Connect to finish processing the new build (#{latest_build.train_version} - #{latest_build.build_version})")
      end

      UI.user_error!("Error receiving the newly uploaded binary, please check iTunes Connect") if latest_build.nil?
      full_build = nil

      while full_build.nil? || full_build.processing
        # The build's processing state should go from true to false, and be done. But sometimes it goes true -> false ->
        # true -> false, where the second true is transient. This causes a spurious failure. Find build by build_version
        # and ensure it's not processing before proceeding - it had to have already been false before, to get out of the
        # previous loop.
        full_build = app.build_trains(platform: platform)[latest_build.train_version].builds.find do |b|
          b.build_version == latest_build.build_version
        end
        if sleep_time > 0
          UI.message("Waiting for iTunes Connect to finish processing the new build (#{latest_build.train_version} - #{latest_build.build_version})")
          sleep(sleep_time)
        else
          return nil
        end
      end

      if full_build && !full_build.processing && full_build.valid
        minutes = ((Time.now - start_time) / 60).round
        UI.success("Successfully finished processing the build")
        UI.message("You can now tweet: ")
        UI.important("iTunes Connect #iosprocessingtime #{minutes} minutes")
        return full_build
      else
        UI.user_error!("Error: Seems like iTunes Connect didn't properly pre-process the binary")
      end
    end

    private_class_method :wait_for_train
  end
end
