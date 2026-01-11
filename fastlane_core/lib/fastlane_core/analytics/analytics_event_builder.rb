module FastlaneCore
  class AnalyticsEventBuilder
    attr_accessor :action_name

    # fastlane_client_language valid options are :ruby or :swift
    def initialize(p_hash: nil, session_id: nil, action_name: nil, fastlane_client_language: :ruby, platform: nil)
      @p_hash = p_hash
      @session_id = session_id
      @action_name = action_name
      @fastlane_client_language = fastlane_client_language
      @platform = platform
    end

    def new_event(action_stage)
      custom_params = {}

      # Add Ruby version
      custom_params[:ruby_version] = RUBY_VERSION

      # Add Xcode version (only for iOS/macOS platforms)
      if @platform == :ios || @platform == :mac
        xcode_ver = Helper.xcode_version
        custom_params[:xcode_version] = xcode_ver if xcode_ver
      end

      # Add platform
      custom_params[:platform] = @platform.to_s if @platform

      # Add fastlane client language
      custom_params[:client_language] = @fastlane_client_language.to_s

      {
        client_id: @p_hash,
        category: "fastlane Client Language - #{@fastlane_client_language}",
        action: action_stage,
        label: action_name,
        value: nil,
        custom_params: custom_params
      }
    end
  end
end
