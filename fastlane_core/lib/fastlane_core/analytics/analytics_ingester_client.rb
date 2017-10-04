module FastlaneCore
  class AnalyticsIngesterClient
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
