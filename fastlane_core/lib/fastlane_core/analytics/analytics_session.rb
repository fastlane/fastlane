module FastlaneCore
  class AnalyticsSession
    attr_accessor :p_hash
    attr_accessor :session_id
    attr_accessor :client

    def initialize(p_hash: nil, analytics_ingester_client: nil)
      @p_hash = p_hash
      @client = analytics_ingester_client
    end

    def action_launched(launch_context: nil)
      client.launched_event(session: self, action_launched_context: launch_context)
    end

    def action_completed(completion_context: nil)
      client.completed_event(session: self, action_completed_context: completion_context)
    end
  end
end
