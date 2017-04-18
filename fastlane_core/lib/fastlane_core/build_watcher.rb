module FastlaneCore
  class BuildWatcher
    def self.wait_for_build_processing_to_be_complete(provider_id, app_id, train_version: nil, build_version: nil, platform: nil)
      build_to_wait_for = wait_for_build_processing_to_be_complete(provider_id, app_id,
                                                      build_version: build.build_version,
                                              train_version: build.train_version,
                                       platform: platform,
                                       current_build: nil)
      # We have the reference to the build, and its train version and build version
      # we just need to wait for it to appear again in the list
      TestFlight::Build.all_builds()
    end

    # @param train_version and build_version are used internally
    def self.wait_for_build_processing_to_be_complete(provider_id, app_id, train_version: nil, build_version: nil, platform: nil, current_build: nil)
      processing = TestFlight::Build.all_processing_builds(provider_id: provider_id, app_id: app_id, platform: platform)

      if processing.count == 0
        # If build is already done by the time we call this method, we'll just grab the latest one as a fallback
        return current_build || TestFlight::Build.latest(provider_id: Spaceship::Application.client.team_id, app_id: app_id, platform: platform)
      end
      
      if train_version && build_version
        # We already have a specific build we wait for, use that one
        build = processing.find { |bd| bd.train_version == train_version && bd.build_version == build_version }
        return current_build if build.nil? # wohooo, the build doesn't show up in the `processing` list any more, we're good
      else
        # Fetch the most recent build, as we want to wait for that one
        # any previous builds might be there since they're stuck
        build = processing.sort_by(&:upload_date).last
      end

      # We got the build we want to wait for, wait now...
      sleep(10)

      UI.message("Waiting for iTunes Connect to finish processing the new build (#{build.train_version} - #{build.build_version})")
      # we don't have access to FastlaneCore::UI in spaceship
      return wait_for_build_processing_to_be_complete(provider_id, app_id,
                                                      build_version: build.build_version,
                                              train_version: build.train_version,
                                       platform: platform,
                                       current_build: build)

      # Also when it's finished we used to do
      # UI.success("Successfully finished processing the build")
      # UI.message("You can now tweet: ")
      # UI.important("iTunes Connect #iosprocessingtime #{minutes} minutes")
    end
  end
end
