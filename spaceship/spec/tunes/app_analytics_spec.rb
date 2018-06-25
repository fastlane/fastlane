require 'spec_helper'
require 'pp'

describe Spaceship::Tunes::AppAnalytics do
  before { Spaceship::Tunes.login }

  let(:app) { Spaceship::Application.all.first }

  describe "App Analytics Grabbed Properly" do
    it "accesses live analytics details" do
      TunesStubbing.itc_stub_analytics

      analytics = app.analytics
      units = analytics.app_units

      pp(units)

      expect(units['size']).to eq(1)

      val = units['results'].find do |a|
        a['adamId'].include?('898536088')
      end

      expect(val['meetsThreshold']).to eq(true)
    end

    it "accesses non-live analytics details" do
      TunesStubbing.itc_stub_analytics
      TunesStubbing.itc_stub_no_live_version
      expect do
        analytics = app.analytics
      end.to raise_error("Analytics are only available for live apps.")
    end
  end
end
