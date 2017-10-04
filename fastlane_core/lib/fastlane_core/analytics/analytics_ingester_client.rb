module FastlaneCore
  class AnalyticsIngesterClient
    def launched_event(session: nil, action_launched_context: nil)
      ingester_events = action_launched_events(
        action_launched_context: action_launched_context,
        session: session
      )

      post_events(events: ingester_events)
    end

    def completed_event(session: nil, action_completed_context: nil)
      ingester_events = action_completed_events(
        action_completed_context: action_completed_context,
        session: session
      )

      post_events(events: ingester_events)
    end

    def post_events(events)
      unless Helper.test?
        fork do
          send_request(events: events.to_json)
        end
      end
      return true
    end

    def send_request(json: nil, retries: 2)
      require 'excon'
      url = ENV["FASTLANE_METRICS_URL"] || "https://fastlane-metrics.fabric.io/public"
      Excon.post(
        url,
        body: json,
        headers: { "Content-Type" => 'application/json' }
      )
    rescue
      retries -= 1
      retry if retries >= 0
    end
  end
end
