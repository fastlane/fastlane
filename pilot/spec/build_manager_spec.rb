describe "Build Manager" do
  describe ".truncate_changelog" do
    it "Truncates Changelog" do
      changelog = File.read("./pilot/spec/fixtures/build_manager/changelog_long")
      changelog = Pilot::BuildManager.truncate_changelog(changelog)
      expect(changelog).to eq(File.read("./pilot/spec/fixtures/build_manager/changelog_long_truncated"))
    end
    it "Keeps changelog if short enough" do
      changelog = "1234"
      changelog = Pilot::BuildManager.truncate_changelog(changelog)
      expect(changelog).to eq("1234")
    end
  end
  describe ".sanitize_changelog" do
    it "removes emoji" do
      changelog = "I'm 🦇B🏧an!"
      changelog = Pilot::BuildManager.sanitize_changelog(changelog)
      expect(changelog).to eq("I'm Ban!")
    end
    it "removes emoji before truncating" do
      changelog = File.read("./pilot/spec/fixtures/build_manager/changelog_long")
      changelog = "🎉🎉🎉#{changelog}"
      changelog = Pilot::BuildManager.sanitize_changelog(changelog)
      expect(changelog).to eq(File.read("./pilot/spec/fixtures/build_manager/changelog_long_truncated"))
    end
  end
  describe "distribute submits the build for review" do
    let(:mock_base_client) { "fake testflight base client" }
    let(:mock_base_api_client) { "fake api base client" }
    let(:fake_build_manager) { Pilot::BuildManager.new }
    let(:ready_to_submit_mock_build) do
      Spaceship::TestFlight::Build.new(
        'app_id' => 1,
        'bundleId' => 1,
        'appAdamId' => 1,
        'externalState' => Spaceship::TestFlight::Build::BUILD_STATES[:ready_to_submit],
        'exportCompliance' => {
          'usesEncryption' => true,
          'encryptionUpdated' => false
        },
        'betaReviewInfo' => {
          'contactFirstName' => 'First',
          'contactLastName' => 'Last'
        },
        'build_version' => '123'
      )
    end
    let(:approved_mock_build) do
      Spaceship::TestFlight::Build.new(
        'bundleId' => 1,
        'appAdamId' => 1,
        'externalState' => Spaceship::TestFlight::Build::BUILD_STATES[:approved],
        'exportCompliance' => {
          'usesEncryption' => true,
          'encryptionUpdated' => false
        },
        'betaReviewInfo' => {
          'contactFirstName' => 'First',
          'contactLastName' => 'Last'
        }
      )
    end
    let(:distribute_options) do
      {
        apple_id: 'mock_apple_id',
        app_identifier: 'mock_app_id',
        distribute_external: true,
        groups: ["Blue Man Group"],
        skip_submission: false
      }
    end
    let(:mock_default_external_group) do
      Spaceship::TestFlight::Group.new({
        'id' => 1,
        'name' => 'Group 1',
        'appAdamId' => 123,
        'isDefaultExternalGroup' => false
      })
    end
    let(:mock_api_client_builds) do
      [{ "id" => "123", "attributes" => { "usesNonExemptEncryption" => true } }]
    end
    let(:mock_api_client_builds_with_nil_encryption) do
      [{ "id" => "123" }]
    end
    let(:mock_api_client_build_beta_details) do
      [{ "id" => "321" }]
    end
    let(:mock_api_client_beta_app_localizations) do
      [
        { "id" => "234", "attributes" => { "locale" => "en-us" } },
        { "id" => "432", "attributes" => { "locale" => "en-gb" } }
      ]
    end
    let(:mock_api_client_beta_groups) do
      [
        { "id" => "987", "attributes" => { "name" => "Blue Man Group" } },
        { "id" => "654", "attributes" => { "name" => "Green Eggs and Ham" } }
      ]
    end

    describe "distribute failures" do
      before(:each) do
        # default client mocks setup
        allow(fake_build_manager).to receive(:login)
        allow(Spaceship::TestFlight::Base).to receive(:client).and_return(mock_base_client)
        allow(mock_base_client).to receive(:team_id).and_return('')
        allow(mock_base_client).to receive(:get_build).and_return(ready_to_submit_mock_build)
        allow(mock_base_client).to receive(:add_group_to_build)
        allow(Spaceship::TestFlight::Group).to receive(:default_external_group).and_return(mock_default_external_group)

        allow(Spaceship::ConnectAPI::Base).to receive(:client).and_return(mock_base_api_client)
        allow(mock_base_api_client).to receive(:get_builds).and_return(mock_api_client_builds)
        allow(mock_base_api_client).to receive(:patch_beta_app_review_detail).and_return(mock_api_client_builds)
        allow(mock_base_api_client).to receive(:get_build_beta_details).and_return(mock_api_client_build_beta_details)
        allow(mock_base_api_client).to receive(:get_beta_app_localizations).and_return(mock_api_client_beta_app_localizations)
        allow(mock_base_api_client).to receive(:patch_beta_app_localizations)
        allow(mock_base_api_client).to receive(:post_beta_app_localizations)
        allow(mock_base_api_client).to receive(:patch_build_beta_details)
        allow(mock_base_api_client).to receive(:get_beta_groups).and_return(mock_api_client_beta_groups)
        allow(mock_base_api_client).to receive(:add_beta_groups_to_build)
      end

      it "doesnt recover if there is a 504 and the build is not approved" do
        allow(mock_base_api_client).to receive(:post_beta_app_review_submissions).and_raise(Spaceship::Client::InternalServerError, "Server error got 504")
        allow(Spaceship::TestFlight::Build).to receive(:find).and_return(ready_to_submit_mock_build)
        expect(FastlaneCore::UI).to receive(:message).with('Distributing new build to testers:  - ')
        expect(FastlaneCore::UI).to receive(:message).with('Submitting the build for review timed out, trying to recover.')
        expect { fake_build_manager.distribute(distribute_options, build: ready_to_submit_mock_build) }.to raise_error(Spaceship::Client::InternalServerError, "Server error got 504")
      end

      it "recovers if there is a 504 and the build is approved" do
        allow(mock_base_api_client).to receive(:post_beta_app_review_submissions).and_raise(Spaceship::Client::InternalServerError, "Server error got 504")
        allow(Spaceship::TestFlight::Build).to receive(:find).and_return(approved_mock_build)
        expect(FastlaneCore::UI).to receive(:message).with('Distributing new build to testers:  - ')
        expect(FastlaneCore::UI).to receive(:message).with('Submitting the build for review timed out, trying to recover.')
        fake_build_manager.distribute(distribute_options, build: ready_to_submit_mock_build)
      end

      it "throws if there is a different error than 504" do
        allow(mock_base_api_client).to receive(:post_beta_app_review_submissions).and_raise(Spaceship::Client::InternalServerError, "Server error got 500")
        expect { fake_build_manager.distribute(distribute_options, build: ready_to_submit_mock_build) }.to raise_error(Spaceship::Client::InternalServerError, "Server error got 500")
      end

      it "doesnt try to recover if no 504" do
        allow(mock_base_api_client).to receive(:post_beta_app_review_submissions) # pretend it worked.
        expect(FastlaneCore::UI).not_to(receive(:message).with('Submitting the build for review timed out, trying to recover.'))
        fake_build_manager.distribute(distribute_options, build: ready_to_submit_mock_build)
      end
    end

    describe "distribute success" do
      let(:distribute_options_non_localized) do
        {
          apple_id: 'mock_apple_id',
          app_identifier: 'mock_app_id',
          distribute_external: true,
          groups: ["Blue Man Group"],
          skip_submission: false,
          demo_account_required: true,
          notify_external_testers: true,
          beta_app_feedback_email: "josh+oldfeedback@rokkincat.com",
          beta_app_description: "old description for all the things",
          uses_non_exempt_encryption: false
        }
      end

      before(:each) do
        # default client mocks setup
        allow(fake_build_manager).to receive(:login)
        allow(Spaceship::TestFlight::Base).to receive(:client).and_return(mock_base_client)
        allow(mock_base_client).to receive(:team_id).and_return('')
        allow(mock_base_client).to receive(:get_build).and_return(ready_to_submit_mock_build)
        allow(mock_base_client).to receive(:add_group_to_build)
        allow(Spaceship::TestFlight::Group).to receive(:default_external_group).and_return(mock_default_external_group)

        allow(mock_base_api_client).to receive(:post_beta_app_review_submissions) # pretend it worked.
        allow(Spaceship::ConnectAPI::Base).to receive(:client).and_return(mock_base_api_client)
      end

      it "updates non-localized  demo_account_required, notify_external_testers, beta_app_feedback_email, and beta_app_description" do
        options = distribute_options_non_localized
        builds = mock_api_client_builds_with_nil_encryption

        # Receive 1: finding build for patching review information
        # Receive 2: finding build for patching uses non-exempt encryption
        # Receive 3: finding build for submitting for review
        # Receive 3: finding build for adding beta groups
        expect(mock_base_api_client).to receive(:get_builds).with({
          filter: { expired: false, processingState: "PROCESSING,VALID", version: ready_to_submit_mock_build.build_version, "preReleaseVersion.version" => ready_to_submit_mock_build.train_version, app: ready_to_submit_mock_build.app_id }
        }).and_return(builds).exactly(4).times

        # Demo account
        expect(mock_base_api_client).to receive(:patch_beta_app_review_detail).with({
          app_id: ready_to_submit_mock_build.app_id,
          attributes: { demoAccountRequired: options[:demo_account_required] }
        })

        # Auto notify
        expect(mock_base_api_client).to receive(:get_build_beta_details).with({
          filter: { build: builds.first['id'] }
        }).and_return(mock_api_client_build_beta_details)
        expect(mock_base_api_client).to receive(:patch_build_beta_details).with({
          build_beta_details_id: mock_api_client_build_beta_details.first['id'],
          attributes: { autoNotifyEnabled: options[:notify_external_testers] }
        })

        # Feedback email and marketing url set for all localizations
        expect(mock_base_api_client).to receive(:get_beta_app_localizations).with({
          filter: { app: ready_to_submit_mock_build.app_id }
        }).and_return(mock_api_client_beta_app_localizations)
        mock_api_client_beta_app_localizations.each do |localization|
          expect(mock_base_api_client).to receive(:patch_beta_app_localizations).with({
            localization_id: localization['id'],
            attributes: {
              feedbackEmail: options[:beta_app_feedback_email],
              description: options[:beta_app_description]
            }
          })
        end
        expect(FastlaneCore::UI).to receive(:success).with("Successfully set the beta_app_feedback_email and/or beta_app_description")

        # Get beta group
        expect(mock_base_api_client).to receive(:get_beta_groups).with({
          filter: { app: ready_to_submit_mock_build.app_id }
        }).and_return(mock_api_client_beta_groups)

        # Add beta group
        expect(mock_base_api_client).to receive(:add_beta_groups_to_build)

        expect(FastlaneCore::UI).to receive(:message).with(/Distributing new build to testers/)
        expect(mock_base_api_client).to receive(:patch_builds).with({
          build_id: builds.first["id"], attributes: { usesNonExemptEncryption: false }
        }).and_return(mock_api_client_beta_app_localizations)
        expect(fake_build_manager).to receive(:wait_for_build_processing_to_be_complete)

        expect(FastlaneCore::UI).to receive(:success).with(/Successfully distributed build to/)

        fake_build_manager.distribute(options, build: ready_to_submit_mock_build)
      end
    end
  end
end
