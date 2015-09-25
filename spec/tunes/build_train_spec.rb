require 'spec_helper'

describe Spaceship::Tunes::BuildTrain do
  before { Spaceship::Tunes.login }
  subject { Spaceship::Tunes.client }
  let(:username) { 'spaceship@krausefx.com' }
  let(:password) { 'so_secret' }

  describe "properly parses the train" do
    let(:app) { Spaceship::Application.all.first }

    it "inspect works" do
      expect(Spaceship::Application.all.first.build_trains.values.first.inspect).to include("Tunes::BuildTrain")
    end

    it "works filled in all required values" do
      trains = app.build_trains

      expect(trains.count).to eq(2)
      train = trains.values.first

      expect(train.version_string).to eq("0.9.10")
      expect(train.platform).to eq("ios")
      expect(train.application).to eq(app)

      # TestFlight
      expect(trains.values.first.testing_enabled).to eq(false)
      expect(trains.values.last.testing_enabled).to eq(true)
    end

    it "returns all processing builds" do
      builds = app.all_processing_builds
      expect(builds.count).to eq(3)

      b = builds.first
      expect(b.state).to eq('ITC.apps.betaProcessingStatus.Created')
    end

    describe "Accessing builds" do
      it "lets the user fetch the builds for a given train" do
        train = app.build_trains.values.first
        expect(train.builds.count).to eq(1)
      end

      it "lets the user fetch the builds using the version as a key" do
        train = app.build_trains['0.9.10']
        expect(train.version_string).to eq('0.9.10')
        expect(train.platform).to eq('ios')
        expect(train.testing_enabled).to eq(false)
        expect(train.builds.count).to eq(1)
      end
    end

    describe "Processing builds" do
      it "builds that are stuck or pre-processing" do
        expect(app.pre_processing_builds.count).to eq(3)

        created_and_stucked = app.pre_processing_builds.first
        expect(created_and_stucked.upload_date).to eq(1436381720000)
        expect(created_and_stucked.state).to eq("ITC.apps.betaProcessingStatus.Created")
      end

      it "properly extracted the processing builds from a train" do
        train = app.build_trains['0.9.10']
        expect(train.processing_builds.count).to eq(0)
      end
    end

    describe "#update_testing_status" do
      it "just works (tm)" do
        train1 = app.build_trains['0.9.10']
        train2 = app.build_trains['0.9.11']
        expect(train1.testing_enabled).to eq(false)
        expect(train2.testing_enabled).to eq(true)

        train1.update_testing_status!(true, 'internal')

        expect(train1.testing_enabled).to eq(true)
      end
    end
  end
end
