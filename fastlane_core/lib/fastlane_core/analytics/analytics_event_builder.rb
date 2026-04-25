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
        events: [
          {
            name: action_stage.to_s,
            params: {
              action_name: action_name || "unknown",
              session_id: @session_id,
              fastlane_client_language: @fastlane_client_language.to_s,
              fastlane_version: Fastlane::VERSION,
              ruby_version: RUBY_VERSION,
              build_tool_version: @build_tool_version || "unknown"
            }
          }
        ]
      }
    end
  end
end
