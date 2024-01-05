module FastlaneCore
  class AnalyticsEventBuilder
    attr_accessor :action_name

    # fastlane_client_language valid options are :ruby or :swift
    def initialize(p_hash: nil, session_id: nil, action_name: nil, fastlane_client_language: :ruby)
      @p_hash = p_hash
      @session_id = session_id
      @action_name = action_name
      @fastlane_client_language = fastlane_client_language
    end

    def new_event(action_stage)
      {
        client_id: @p_hash,
        category: "fastlane Client Language - #{@fastlane_client_language}",
        action: action_stage,
        label: action_name,
        value: nil
      }
    end
  end
end
