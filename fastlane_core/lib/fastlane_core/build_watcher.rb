module FastlaneCore
  class BuildWatcher
    # Just the builds, as a flat array, that are still processing
    def self.all_processing_builds(app_id, platform: nil)
      all_builds = TestFlight::Build.all(app_id, platform: platform)
      result = []
      all_builds.each do |train_version, builds|
        result += builds.find_all do |build|
          build.external_state == "testflight.build.state.processing"
        end
      end
      return result
    end

    # @param train_version and build_version are used internally
    def self.wait_for_build_processing_to_be_complete(app_id, train_version: nil, build_version: nil, platform: nil, start_time: Time.now, build_to_look_for: nil)
      processing = all_processing_builds(app_id, platform: platform)
      if processing.count == 0
        UI.success "No Builds in processing state"
        return
      end

      if train_version && build_version
        # We already have a specific build we wait for, use that one
        build = processing.find { |b| b.train_version == train_version && b.build_version == build_version }
        if build.nil?
          # wohooo, the build doesn't show up in the `processing` list any more, we're good
          minutes = ((Time.now - start_time) / 60).round
          UI.success("Successfully finished processing the build")
          UI.message("You can now tweet: ")
          UI.important("iTunes Connect #iosprocessingtime #{minutes} minutes")
          # Return the Build
          return build_to_look_for
        end
      else
        # Fetch the most recent build, as we want to wait for that one
        # any previous builds might be there since they're stuck
        build = processing.sort_by(&:upload_date).last
      end

      # We got the build we want to wait for, wait now...
      sleep(10)
      UI.message("Waiting for iTunes Connect to finish processing the new build (#{build.train_version} - #{build.build_version})")
      wait_for_build_processing_to_be_complete(app_id,
                                               build_version: build.build_version,
                                               train_version: build.train_version,
                                               platform: platform,
                                               start_time: start_time,
                                               build_to_look_for: build)
    end
  end
end
