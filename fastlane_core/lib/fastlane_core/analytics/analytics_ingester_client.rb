require 'faraday'
require 'openssl'
require 'json'
require 'uri'

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
        conn.adapter(Faraday.default_adapter)
      end
      connection.headers[:user_agent] = 'fastlane/' + Fastlane::VERSION

      # GA4 Client-Side Collection endpoint (similar to gtag.js)
      # Using /g/collect which doesn't require api_secret (unlike /mp/collect)
      params = {
        v: "2",                                           # Protocol version
        tid: @ga_tracking,                                # Measurement ID
        cid: event[:client_id],                           # Client ID
        en: event[:action].to_s,                          # Event name
        _dbg: "1"                                         # Debug mode (helpful for validation)
      }

      # Add custom parameters as event parameters
      if event[:custom_params]
        event[:custom_params].each do |key, value|
          params["ep.#{key}"] = value.to_s if value
        end
      end

      # Add standard event parameters
      params["ep.event_category"] = event[:category] if event[:category]
      params["ep.event_label"] = event[:label] || "na"
      params["ep.value"] = event[:value] || 0

      response = connection.post("/g/collect") do |req|
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.body = URI.encode_www_form(params)
      end

      # Log response for debugging
      unless Helper.test?
        UI.verbose("GA4 Response: #{response.status}")
        UI.verbose("GA4 Response Body: #{response.body}") if response.body && !response.body.empty?
      end

      response
    end
  end
end
