module FastlaneCore
  class AnalyticsIngesterClient
    def post_events(events)
      unless Helper.test?
        fork do
          send_request(json: events.to_json)
        end
      end
      return true
    end

    def send_request(json: nil, retries: 2)
      post_request(body: json)
    rescue
      retries -= 1
      retry if retries >= 0
    end

    def post_request(body: nil)
      require 'excon'
      url = ENV["FASTLANE_METRICS_URL"] || "https://fastlane-metrics.fabric.io/public"
      Excon.post(
        url,
        body: body,
        headers: { "Content-Type" => 'application/json' }
      )
    end
  end

  class MockAnalyticsIngesterClient < AnalyticsIngesterClient
    def post_request(body: nil)
      output_file = File.new("#{ENV['HOME']}/Desktop/mock_analytics.json", 'w')
      output_file.write(body)
    end
  end
end
