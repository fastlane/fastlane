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
    let(:fake_build_manager) { Pilot::BuildManager.new }
    let(:ready_to_submit_mock_build) do
      Spaceship::TestFlight::Build.new(
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
        }
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

    before(:each) do
      # default client mocks setup
      allow(fake_build_manager).to receive(:login)
      allow(Spaceship::TestFlight::Base).to receive(:client).and_return(mock_base_client)
      allow(mock_base_client).to receive(:team_id).and_return('')
      allow(mock_base_client).to receive(:get_build).and_return(ready_to_submit_mock_build)
      allow(mock_base_client).to receive(:add_group_to_build)
      allow(Spaceship::TestFlight::Group).to receive(:default_external_group).and_return(mock_default_external_group)
      # used to return the approved build if we recover from the 504
      allow(Spaceship::TestFlight::Build).to receive(:find).and_return(approved_mock_build)
    end
    it "recovers if there is a 504" do
      allow(mock_base_client).to receive(:post_for_testflight_review).and_raise(Spaceship::Client::InternalServerError, "Server error got 504")
      expect(FastlaneCore::UI).to receive(:message).with('Distributing new build to testers:  - ')
      expect(FastlaneCore::UI).to receive(:message).with('Submitting the build for review timed out, trying to recover.')
      fake_build_manager.distribute(distribute_options, build: ready_to_submit_mock_build)
    end
    it "throws if there is a different error than 504" do
      allow(mock_base_client).to receive(:post_for_testflight_review).and_raise(Spaceship::Client::InternalServerError, "Server error got 500")
      expect { fake_build_manager.distribute(distribute_options, build: ready_to_submit_mock_build) }.to raise_error(Spaceship::Client::InternalServerError, "Server error got 500")
    end
    it "doesnt try to recover if no 504" do
      allow(mock_base_client).to receive(:post_for_testflight_review) # pretend it worked.
      expect(FastlaneCore::UI).not_to(receive(:message).with('Submitting the build for review timed out, trying to recover.'))
      fake_build_manager.distribute(distribute_options, build: ready_to_submit_mock_build)
    end
  end
end
