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
    let(:mock_base_client) { "fake api base client" }
    let(:fake_build_manager) { Pilot::BuildManager.new }

    let(:app) do
      Spaceship::ConnectAPI::App.new("123-123-123-123", {
        name: "Mock App"
      })
    end
    let(:pre_release_version) do
      Spaceship::ConnectAPI::PreReleaseVersion.new("123-123-123-123", {
        version: "1.0"
      })
    end
    let(:app_localizations) do
      [
        Spaceship::ConnectAPI::BetaAppLocalization.new("234", {
          feedbackEmail: 'email@email.com',
          marketingUrl: 'https://url.com',
          privacyPolicyUrl: 'https://url.com',
          description: 'desc desc desc',
          locale: 'en-us'
        }),
        Spaceship::ConnectAPI::BetaAppLocalization.new("432", {
          feedbackEmail: 'email@email.com',
          marketingUrl: 'https://url.com',
          privacyPolicyUrl: 'https://url.com',
          description: 'desc desc desc',
          locale: 'en-gb'
        })
      ]
    end
    let(:build_localizations) do
      [
        Spaceship::ConnectAPI::BetaBuildLocalization.new("234", {
          whatsNew: 'some more words',
          locale: 'en-us'
        }),
        Spaceship::ConnectAPI::BetaBuildLocalization.new("432", {
          whatsNew: 'some words',
          locale: 'en-gb'
        })
      ]
    end
    let(:build_beta_detail) do
      Spaceship::ConnectAPI::BuildBetaDetail.new("321", {
        external_build_state: Spaceship::ConnectAPI::BuildBetaDetail::ExternalState::READY_FOR_BETA_SUBMISSION
      })
    end
    let(:beta_groups) do
      [
        Spaceship::ConnectAPI::BetaGroup.new("987", {
          name: "Blue Man Group"
        }),
        Spaceship::ConnectAPI::BetaGroup.new("654", {
          name: "Green Eggs and Ham"
        })
      ]
    end
    let(:ready_to_submit_mock_build) do
      Spaceship::ConnectAPI::Build.new("123", {
        version: '',
        uploadedDate: '',
        processingState: Spaceship::ConnectAPI::Build::ProcessingState::VALID,
        usesNonExemptEncryption: nil
      })
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
    let(:mock_api_client_beta_app_localizations) do
      [
        { "id" => "234", "attributes" => { "locale" => "en-us" } },
        { "id" => "432", "attributes" => { "locale" => "en-gb" } }
      ]
    end
    let(:mock_api_client_beta_build_localizations) do
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

    #    describe "distribute failures" do
    #      before(:each) do
    #        # default client mocks setup
    #        allow(fake_build_manager).to receive(:login)
    #        allow(Spaceship::TestFlight::Base).to receive(:client).and_return(mock_base_client)
    #        allow(mock_base_client).to receive(:team_id).and_return('')
    #
    #        allow(Spaceship::ConnectAPI::Build).to receive(:all).and_return([ready_to_submit_mock_build])
    #
    ##        allow(Spaceship::ConnectAPI::Base).to receive(:client).and_return(mock_base_api_client)
    ##        allow(mock_base_api_client).to receive(:get_builds).and_return(mock_api_client_builds)
    #        allow(mock_base_api_client).to receive(:patch_beta_app_review_detail).and_return(mock_api_client_builds)
    ##        allow(mock_base_api_client).to receive(:get_build_beta_details).and_return(mock_api_client_build_beta_details)
    ##        allow(mock_base_api_client).to receive(:get_beta_app_localizations).and_return(mock_api_client_beta_app_localizations)
    #        allow(mock_base_api_client).to receive(:patch_beta_app_localizations)
    #        allow(mock_base_api_client).to receive(:post_beta_app_localizations)
    #        allow(mock_base_api_client).to receive(:patch_build_beta_details)
    ##        allow(mock_base_api_client).to receive(:get_beta_groups).and_return(mock_api_client_beta_groups)
    ##        allow(mock_base_api_client).to receive(:add_beta_groups_to_build)
    #      end
    #
    #      it "throws if there is a different error than 504" do
    #        allow(mock_base_api_client).to receive(:post_beta_app_review_submissions).and_raise(Spaceship::Client::InternalServerError, "Server error got 500")
    #        expect { fake_build_manager.distribute(distribute_options, build: ready_to_submit_mock_build) }.to raise_error(Spaceship::Client::InternalServerError, "Server error got 500")
    #      end
    #
    #      it "doesnt try to recover if no 504" do
    #        allow(mock_base_api_client).to receive(:post_beta_app_review_submissions) # pretend it worked.
    #        expect(FastlaneCore::UI).not_to(receive(:message).with('Submitting the build for review timed out, trying to recover.'))
    #        fake_build_manager.distribute(distribute_options, build: ready_to_submit_mock_build)
    #      end
    #    end

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
          uses_non_exempt_encryption: false,
          changelog: "log of changing"
        }
      end

      before(:each) do
        allow(fake_build_manager).to receive(:login)
        allow(mock_base_client).to receive(:team_id).and_return('')

        allow(mock_base_client).to receive(:post_beta_app_review_submissions) # pretend it worked.
        allow(Spaceship::ConnectAPI::Base).to receive(:client).and_return(mock_base_client)

        # Allow build to return app, buidl_beta_detail, and pre_release_version
        # These are models that are expected to usually be included in the build passed into distribute
        allow(ready_to_submit_mock_build).to receive(:app).and_return(app)
        allow(ready_to_submit_mock_build).to receive(:build_beta_detail).and_return(build_beta_detail)
        allow(ready_to_submit_mock_build).to receive(:pre_release_version).and_return(pre_release_version)
      end

      it "updates non-localized  demo_account_required, notify_external_testers, beta_app_feedback_email, and beta_app_description" do
        options = distribute_options_non_localized

        # Expect App.find to be called from within Pilot::Manager
        expect(Spaceship::ConnectAPI::App).to receive(:find).and_return(app)

        # Expect a beta app review detail to be patched
        expect(mock_base_client).to receive(:patch_beta_app_review_detail).with({
          app_id: ready_to_submit_mock_build.app_id,
          attributes: { demoAccountRequired: options[:demo_account_required] }
        })

        # Expect beta app localizations to be fetched
        expect(mock_base_client).to receive(:get_beta_app_localizations).with({
          filter: { app: ready_to_submit_mock_build.app.id },
          includes: nil,
          limit: nil,
          sort: nil
        }).and_return(Spaceship::ConnectAPI::Response.new)
        expect(app).to receive(:get_beta_app_localizations).and_wrap_original do |m, *args|
          m.call(*args)
          app_localizations
        end

        # Expect beta app localizations to be patched with a UI.success after
        mock_api_client_beta_app_localizations.each do |localization|
          expect(mock_base_client).to receive(:patch_beta_app_localizations).with({
            localization_id: localization['id'],
            attributes: {
              feedbackEmail: options[:beta_app_feedback_email],
              description: options[:beta_app_description]
            }
          })
        end
        expect(FastlaneCore::UI).to receive(:success).with("Successfully set the beta_app_feedback_email and/or beta_app_description")

        # Expect beta build localizations to be fetched
        expect(mock_base_client).to receive(:get_beta_build_localizations).with({
          filter: { build: ready_to_submit_mock_build.id },
          includes: nil,
          limit: nil,
          sort: nil
        }).and_return(Spaceship::ConnectAPI::Response.new)
        expect(ready_to_submit_mock_build).to receive(:get_beta_build_localizations).and_wrap_original do |m, *args|
          m.call(*args)
          build_localizations
        end

        # Expect beta build localizations to be patched with a UI.success after
        mock_api_client_beta_build_localizations.each do |localization|
          expect(mock_base_client).to receive(:patch_beta_build_localizations).with({
            localization_id: localization['id'],
            attributes: {
              whatsNew: options[:changelog]
            }
          })
        end
        expect(FastlaneCore::UI).to receive(:success).with("Successfully set the changelog for build")

        # Expect build beta details to be patched
        expect(mock_base_client).to receive(:patch_build_beta_details).with({
          build_beta_details_id: build_beta_detail.id,
          attributes: { autoNotifyEnabled: options[:notify_external_testers] }
        })

        # A build will go back into a processing state after a patch
        # Expect wait_for_build_processing_to_be_complete to be called after patching
        expect(mock_base_client).to receive(:patch_builds).with({
          build_id: ready_to_submit_mock_build.id, attributes: { usesNonExemptEncryption: false }
        })
        expect(fake_build_manager).to receive(:wait_for_build_processing_to_be_complete)

        # Expect beta groups fetched from app. This tests:
        # 1. app.get_beta_groups is called
        # 2. client.get_beta_groups is called inside of app.beta_groups
        expect(mock_base_client).to receive(:get_beta_groups).with({
          filter: { app: ready_to_submit_mock_build.app.id },
          includes: nil,
          limit: nil,
          sort: nil
        }).and_return(Spaceship::ConnectAPI::Response.new)
        expect(app).to receive(:get_beta_groups).and_wrap_original do |m, *args|
          m.call(*args)
          beta_groups
        end

        # Expect beta groups to be added to a builds. This tests:
        # 1. build.add_beta_groups is called
        # 2. client.add_beta_groups_to_build is called inside of build.add_beta_groups
        expect(mock_base_client).to receive(:add_beta_groups_to_build).with({
          build_id: ready_to_submit_mock_build.id,
          beta_group_ids: [beta_groups[0].id]
        }).and_return(Spaceship::ConnectAPI::Response.new)
        expect(ready_to_submit_mock_build).to receive(:add_beta_groups).with(beta_groups: [beta_groups[0]]).and_wrap_original do |m, *args|
          m.call(*args)
        end

        # Except success messages
        expect(FastlaneCore::UI).to receive(:message).with(/Distributing new build to testers/)
        expect(FastlaneCore::UI).to receive(:success).with(/Successfully distributed build to/)

        fake_build_manager.distribute(options, build: ready_to_submit_mock_build)
      end
    end
  end
end
