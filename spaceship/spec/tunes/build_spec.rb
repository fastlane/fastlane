require 'spec_helper'

describe Spaceship::Tunes::Build do
  before { Spaceship::Tunes.login }
  subject { Spaceship::Tunes.client }
  let(:username) { 'spaceship@krausefx.com' }
  let(:password) { 'so_secret' }

  describe "properly parses the build from the train" do
    let(:app) { Spaceship::Application.all.first }

    it "inspect works" do
      expect(Spaceship::Application.all.first.build_trains.values.first.builds.first.inspect).to include("Tunes::Build")
    end

    it "filled in all required values" do
      train = app.build_trains.values.first
      build = train.builds.first

      expect(build.build_train).to eq(train)
      expect(build.upload_date).to eq(1_443_144_470_000)
      expect(build.valid).to eq(true)
      expect(build.id).to eq(5_577_102)
      expect(build.build_version).to eq("10")
      expect(build.train_version).to eq("1.0")
      expect(build.icon_url).to eq('https://is3-ssl.mzstatic.com/image/thumb/Newsstand3/v4/94/80/28/948028c9-59e7-7b29-e75b-f57e97421ece/Icon-76@2x.png.png/150x150bb-80.png')
      expect(build.app_name).to eq('Updated by fastlane')
      expect(build.platform).to eq('ios')
      expect(build.internal_expiry_date).to eq(1_445_737_214_000)
      expect(build.external_expiry_date).to eq(0)
      expect(build.internal_testing_enabled).to eq(true)
      expect(build.external_testing_enabled).to eq(false)
      expect(build.watch_kit_enabled).to eq(false)
      expect(build.ready_to_install).to eq(true)

      # Analytics
      expect(build.install_count).to eq(0)
      expect(build.internal_install_count).to eq(0)
      expect(build.external_install_count).to eq(0)
      expect(build.session_count).to eq(0)
      expect(build.crash_count).to eq(0)
    end

    describe "#testing_status" do
      before do
        now = Time.at(1_444_440_842)
        allow(Time).to receive(:now) { now }
      end

      it "properly describes a build" do
        build1 = app.build_trains.values.first.builds.first
        expect(build1.testing_status).to eq("Internal")

        build2 = app.build_trains.values.last.builds.first
        expect(build2.testing_status).to eq("Inactive")
      end
    end

    describe "submitting/rejecting a build" do
      before do
        train = app.build_trains.values.first
        @build = train.builds.first
      end

      it "#cancel_beta_review!" do
        @build.cancel_beta_review!
      end

      it "#submit_for_beta_review!" do
        r = @build.submit_for_beta_review!({
          changelog: "Custom Changelog"
        })

        expect(r).to eq({
          app_id: "898536088",
          train: "1.0",
          build_number: "10",
          platform: "ios",
          changelog: "Custom Changelog",
          description: "No app description provided",
          feedback_email: "contact@company.com",
          marketing_url: "http://marketing.com",
          first_name: "Felix",
          last_name: "Krause",
          review_email: "contact@company.com",
          phone_number: "0123456789",
          significant_change: false,
          privacy_policy_url: nil,
          review_user_name: nil,
          review_password: nil,
          encryption: false })
      end
    end
  end
end
