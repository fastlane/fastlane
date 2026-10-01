require 'faraday'
require 'openssl'
require 'json'

require_relative '../helper'

module FastlaneCore
  class AnalyticsIngesterClient
    GA_URL = "https://www.google-analytics.com"

    private_constant :GA_URL

    def initialize(ga_tracking)
      @ga_tracking = ga_tracking
    end

    def post_event(event)
      # If our users want to opt out of usage metrics, don't post the events.
      # Learn more at https://docs.fastlane.tools/#metrics
      if Helper.test? || FastlaneCore::Env.truthy?("FASTLANE_OPT_OUT_USAGE")
        return nil
      end
      return Thread.new do
        send_request(event)
      end
    end

    def send_request(event, retries: 2)
      post_request(event)
    rescue
      retries -= 1
      retry if retries >= 0
    end

    def post_request(event)
      connection = Faraday.new(GA_URL) do |conn|
        # This request runs while fastlane is shutting down,
        # so keep the timeouts short to not delay the user
        conn.options.open_timeout = 5
        conn.options.timeout = 5
        conn.adapter(Faraday.default_adapter)
      end
      connection.headers[:user_agent] = 'fastlane/' + Fastlane::VERSION

      # GA4 protocol, event parameters are sent as `ep.<name>` query parameters
      params = {
        v: "2",                        # Protocol version (GA4)
        tid: @ga_tracking,             # GA4 measurement ID
        cid: event[:client_id],        # Client ID
        sid: event[:session_id],       # Session ID
        _ss: "1",                      # Session start
        seg: "1",                      # Session engaged
        # Engagement time in ms, required for events to count towards active users
        _et: (event[:engagement_time_msec] || 100).to_s,
        en: event[:name].to_s          # Event name
      }
      (event[:params] || {}).each do |key, value|
        params["ep.#{key}"] = value.to_s
      end

      connection.post("/g/collect") do |request|
        request.params = params
      end
    end
  end
end
