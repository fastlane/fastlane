require 'spec_helper'

describe Spaceship::Tunes::AppDetails do
  before { Spaceship::Tunes.login }

  let(:client) { Spaceship::AppVersion.client }
  let(:app) { Spaceship::Application.all.first }

  describe "App Details are properly loaded" do
    it "contains all the relevant information" do
      details = app.details

      expect(details.name['en-US']).to eq("Updated by fastlane")
      expect(details.privacy_url['en-US']).to eq('https://fastlane.tools')
      expect(details.primary_category).to eq('MZGenre.Sports')
    end
  end

  describe "Modifying the app category" do
    it "prefixes the category with the correct value for all category types" do
      details = app.details

      details.primary_category = "Weather"
      expect(details.primary_category).to eq("MZGenre.Weather")

      details.primary_first_sub_category = "Weather"
      expect(details.primary_first_sub_category).to eq("MZGenre.Weather")

      details.primary_second_sub_category = "Weather"
      expect(details.primary_second_sub_category).to eq("MZGenre.Weather")

      details.secondary_category = "Weather"
      expect(details.secondary_category).to eq("MZGenre.Weather")

      details.secondary_first_sub_category = "Weather"
      expect(details.secondary_first_sub_category).to eq("MZGenre.Weather")

      details.secondary_second_sub_category = "Weather"
      expect(details.secondary_second_sub_category).to eq("MZGenre.Weather")
    end

    it "doesn't prefix if the prefix is already there" do
      details = app.details

      details.primary_category = "MZGenre.Weather"
      expect(details.primary_category).to eq("MZGenre.Weather")
    end
  end
end
