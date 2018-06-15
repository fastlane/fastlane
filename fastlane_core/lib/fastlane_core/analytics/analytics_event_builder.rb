module FastlaneCore
  class AnalyticsEventBuilder
    attr_accessor :action_name

    def initialize(p_hash: nil, session_id: nil, action_name: nil)
      @p_hash = p_hash
      @session_id = session_id
      @action_name = action_name
    end

    def new_event(stage)
      {
        client_id: @session_id,
        category: "und",
        action: stage,
        label: action_name,
        value: nil
      }
    end
  end
end
