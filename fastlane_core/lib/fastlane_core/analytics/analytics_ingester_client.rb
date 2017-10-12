module FastlaneCore
  class AnalyticsIngesterClient
    def post_events(events)
      unless Helper.test?
        fork do
          send_request(json: { analytics: events }.to_json)
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
      if ENV['METRICS_DEBUG']
        write_json(body)
      end
      url = ENV["FASTLANE_METRICS_URL"] || "https://fastlane-metrics.fabric.io"

      require 'faraday'
      connection = Faraday.new(url) do |conn|
        conn.adapter Faraday.default_adapter
        if ENV['METRICS_DEBUG']
          conn.proxy = "https://127.0.0.1:8888"
          conn.ssl[:verify_mode] = OpenSSL::SSL::VERIFY_NONE
        end
      end
      connection.post do |req|
        req.url '/public'
        req.headers['Content-Type'] = 'application/json'
        req.body = body
      end
    end

    def write_json(body)
      output_file = File.new("#{ENV['HOME']}/Desktop/mock_analytics-#{Time.now.to_i}.json", 'w')
      output_file.write(body)
    end
  end

  class MockAnalyticsIngesterClient < AnalyticsIngesterClient
    def post_request(body: nil)
      write_json(body)
    end
  end
end
