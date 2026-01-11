require 'fastlane_core/analytics/analytics_event_builder'
require 'fastlane_core/helper'

describe FastlaneCore::AnalyticsEventBuilder do
  describe "#new_event" do
    it "includes Ruby version in custom params" do
      builder = FastlaneCore::AnalyticsEventBuilder.new(
        p_hash: "test_hash",
        session_id: "test_session",
        action_name: "test_action",
        fastlane_client_language: :ruby,
        platform: :ios
      )

      event = builder.new_event(:launch)

      expect(event[:custom_params][:ruby_version]).to eq(RUBY_VERSION)
    end

    it "includes Xcode version for iOS platform" do
      allow(FastlaneCore::Helper).to receive(:xcode_version).and_return("14.3")
      
      builder = FastlaneCore::AnalyticsEventBuilder.new(
        p_hash: "test_hash",
        session_id: "test_session",
        action_name: "test_action",
        fastlane_client_language: :ruby,
        platform: :ios
      )

      event = builder.new_event(:launch)

      expect(event[:custom_params][:xcode_version]).to eq("14.3")
    end

    it "does not include Xcode version for Android platform" do
      builder = FastlaneCore::AnalyticsEventBuilder.new(
        p_hash: "test_hash",
        session_id: "test_session",
        action_name: "test_action",
        fastlane_client_language: :ruby,
        platform: :android
      )

      event = builder.new_event(:launch)

      expect(event[:custom_params][:xcode_version]).to be_nil
    end

    it "includes platform in custom params" do
      builder = FastlaneCore::AnalyticsEventBuilder.new(
        p_hash: "test_hash",
        session_id: "test_session",
        action_name: "test_action",
        fastlane_client_language: :ruby,
        platform: :ios
      )

      event = builder.new_event(:launch)

      expect(event[:custom_params][:platform]).to eq("ios")
    end

    it "includes client language in custom params" do
      builder = FastlaneCore::AnalyticsEventBuilder.new(
        p_hash: "test_hash",
        session_id: "test_session",
        action_name: "test_action",
        fastlane_client_language: :swift,
        platform: :ios
      )

      event = builder.new_event(:launch)

      expect(event[:custom_params][:client_language]).to eq("swift")
    end

    it "handles nil platform gracefully" do
      builder = FastlaneCore::AnalyticsEventBuilder.new(
        p_hash: "test_hash",
        session_id: "test_session",
        action_name: "test_action",
        fastlane_client_language: :ruby,
        platform: nil
      )

      event = builder.new_event(:launch)

      expect(event[:custom_params][:platform]).to be_nil
      expect(event[:custom_params][:ruby_version]).to eq(RUBY_VERSION)
    end
  end
end
