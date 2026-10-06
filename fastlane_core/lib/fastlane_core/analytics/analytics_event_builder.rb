require_relative '../helper'

module FastlaneCore
  class AnalyticsEventBuilder
    attr_accessor :action_name

    # fastlane_client_language valid options are :ruby or :swift
    def initialize(p_hash: nil, session_id: nil, action_name: nil, fastlane_client_language: :ruby, build_tool_version: nil)
      @p_hash = p_hash
      @session_id = session_id
      @action_name = action_name
      @fastlane_client_language = fastlane_client_language
      @build_tool_version = build_tool_version
    end

    def new_event(action_stage)
      {
        client_id: @p_hash,
        session_id: @session_id,
        name: action_stage,
        params: {
          fastlane_client_language: @fastlane_client_language,
          fastlane_version: Fastlane::VERSION,
          install_method: Helper.install_method,
          ruby_version: RUBY_VERSION,
          operating_system: Helper.operating_system,
          build_tool_version: @build_tool_version,
          ci: Helper.ci?.to_s
        }.reject { |_, value| value.nil? }
      }
    end
  end
end
