require 'spec_helper'

describe Spaceship::Tunes::BuildTrain do
  before { Spaceship::Tunes.login }
  subject { Spaceship::Tunes.client }
  let(:username) { 'spaceship@krausefx.com' }
  let(:password) { 'so_secret' }

  describe "properly parses the train" do
    let (:app) { Spaceship::Application.all.first }
    it "works filled in all required values" do
      trains = app.build_trains

      expect(trains.count).to eq(2)
      train = trains.first

      expect(train.version_string).to eq("0.9.10")
      expect(train.platform).to eq("ios")
      expect(train.application).to eq(app)

      # TestFlight
      expect(trains.first.testflight_testing_enabled).to eq(false)
      expect(trains.last.testflight_testing_enabled).to eq(true)
    end

    describe "Accessing builds" do
      let (:train) { app.build_trains.first }
      it "lets the user fetch the builds for a given train" do
        expect(train.builds.count).to eq(1)
      end
    end
  end
end
