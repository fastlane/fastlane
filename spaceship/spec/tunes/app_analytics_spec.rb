require 'spec_helper'

describe Spaceship::Tunes::AppAnalytics do
  include_examples "common spaceship login"

  let(:app) { Spaceship::Application.all.find { |a| a.apple_id == "898536088" } }

  describe "App Analytics Grabbed Properly" do
    it "accesses live analytics details" do
      start_time, end_time = app.analytics.time_last_7_days
      TunesStubbing.itc_stub_analytics(start_time, end_time)
      analytics = app.analytics

      units = analytics.app_units
      expect(units['size']).to eq(1)
      val = units['results'].find do |a|
        a['adamId'].include?('898536088')
      end
      expect(val['meetsThreshold']).to eq(true)

      views = analytics.app_views
      expect(views['size']).to eq(1)
      val = views['results'].find do |a|
        a['adamId'].include?('898536088')
      end
      expect(val['meetsThreshold']).to eq(true)

      in_app_purchases = analytics.app_in_app_purchases
      expect(in_app_purchases['size']).to eq(1)
      val = in_app_purchases['results'].find do |a|
        a['adamId'].include?('898536088')
      end
      expect(val['meetsThreshold']).to eq(true)

      sales = analytics.app_sales
      expect(sales['size']).to eq(1)
      val = sales['results'].find do |a|
        a['adamId'].include?('898536088')
      end
      expect(val['meetsThreshold']).to eq(true)

      paying_users = analytics.app_paying_users
      expect(paying_users['size']).to eq(1)
      val = paying_users['results'].find do |a|
        a['adamId'].include?('898536088')
      end
      expect(val['meetsThreshold']).to eq(true)

      installs = analytics.app_installs
      expect(installs['size']).to eq(1)
      val = installs['results'].find do |a|
        a['adamId'].include?('898536088')
      end
      expect(val['meetsThreshold']).to eq(true)

      sessions = analytics.app_sessions
      expect(sessions['size']).to eq(1)
      val = sessions['results'].find do |a|
        a['adamId'].include?('898536088')
      end
      expect(val['meetsThreshold']).to eq(true)

      active_devices = analytics.app_active_devices
      expect(active_devices['size']).to eq(1)
      val = active_devices['results'].find do |a|
        a['adamId'].include?('898536088')
      end
      expect(val['meetsThreshold']).to eq(true)

      crashes = analytics.app_crashes
      expect(crashes['size']).to eq(1)
      val = crashes['results'].find do |a|
        a['adamId'].include?('898536088')
      end
      expect(val['meetsThreshold']).to eq(true)

      measure_installs = analytics.app_measure_interval(start_time, end_time, 'installs')
      expect(measure_installs['size']).to eq(1)
      val = measure_installs['results'].find do |a|
        a['adamId'].include?('898536088')
      end
      expect(val['meetsThreshold']).to eq(true)
    end

    it "grabs live analytics split by view_by" do
      start_time, end_time = app.analytics.time_last_7_days
      TunesStubbing.itc_stub_analytics(start_time, end_time)
      analytics = app.analytics
      measure_installs_by_source = analytics.app_measure_interval(start_time, end_time, 'installs', 'source')
      expect(measure_installs_by_source['size']).to eq(5)
      val = measure_installs_by_source['results'].find do |a|
        a['adamId'].include?('898536088')
      end
      expect(val['meetsThreshold']).to eq(true)
    end

    it "accesses non-live analytics details" do
      start_time, end_time = app.analytics.time_last_7_days
      TunesStubbing.itc_stub_analytics(start_time, end_time)
      TunesStubbing.itc_stub_no_live_version
      expect do
        analytics = app.analytics
      end.to raise_error("Analytics are only available for live apps.")
    end
  end
end
