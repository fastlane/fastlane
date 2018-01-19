describe Fastlane do
  describe Fastlane::Action do
    describe "No unused options" do
      let(:all_exceptions) do
        %w(
          pilot
          appstore
          cert
          deliver
          gym
          match
          pem
          produce
          scan
          sigh
          snapshot
          precheck
          supply
          testflight
          mailgun
          testfairy
          ipa
          import_from_git
          hockey
          deploygate
          crashlytics
          artifactory
          appledoc
          slather
          screengrab
          download_dsyms
          notification
          frameit
          set_changelog
          register_device
          register_devices
          latest_testflight_build_number
          app_store_build_number
          sh
          swiftlint
          plugin_scores
          google_play_track_version_codes
          modify_services
          build_app
          build_android_app
          build_ios_app
          capture_screenshots
          capture_android_screenshots
          capture_ios_screenshots
          check_app_store_metadata
          get_certificates
          create_app_online
          frame_screenshots
          get_provisioning_profile
          get_push_certificate
          run_tests
          submit_build_to_app_store
          sync_code_signing
          upload_to_app_store
          upload_to_play_store
          upload_to_testflight
          puts
          println
          echo
        )
      end

      Fastlane::ActionsList.all_actions do |action, name|
        next unless action.available_options.kind_of?(Array)
        next unless action.available_options.last.kind_of?(FastlaneCore::ConfigItem)

        it "No unused parameters in '#{name}'" do
          next if all_exceptions.include?(name)
          content = File.read(File.join("fastlane", "lib", "fastlane", "actions", name + ".rb"))
          action.available_options.each do |option|
            unless content.include?("[:#{option.key}]")
              UI.user_error!("Action '#{name}' doesn't use the option :#{option.key}")
            end
          end
        end
      end
    end
  end
end
