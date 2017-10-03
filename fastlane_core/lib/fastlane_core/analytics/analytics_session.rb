module FastlaneCore
  class AnalyticsSession
    attr_accessor :p_hash
    attr_accessor :session_id
    attr_accessor :client

    def initialize(p_hash: nil, analytic_ingester_client: nil)
      p_hash = p_hash
      client = analytic_ingester_client
    end

    def action_launched(launch_context: nil)
      client.launched_event(session: self, launch_context: launch_context)
    end

    def action_completed(completion_context: nil)
      client.completed_event(session: self, completion_context: completion_context)
    end
  end
end
