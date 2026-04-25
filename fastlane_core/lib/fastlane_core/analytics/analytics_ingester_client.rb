require 'faraday'
require 'openssl'
require 'json'
require 'uri'

require_relative '../helper'

module FastlaneCore
  class AnalyticsIngesterClient
    GA_URL = "https://www.google-analytics.com"

    private_constant :GA_URL

    def initialize(measurement_id, api_secret)
      @measurement_id = measurement_id
      @api_secret = api_secret
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
      connection.headers['Content-Type'] = 'application/json'
      params = URI.encode_www_form(measurement_id: @measurement_id, api_secret: @api_secret)
      connection.post("/mp/collect?#{params}", event.to_json)
    end
  end
end
