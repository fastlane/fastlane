require_relative 'analytics_ingester_client'
require_relative 'action_launch_context'
require_relative 'analytics_event_builder'

module FastlaneCore
  class AnalyticsSession
    GA_TRACKING = "UA-121171860-1"

    private_constant :GA_TRACKING
    attr_accessor :session_id
    attr_accessor :client

    def initialize(analytics_ingester_client: AnalyticsIngesterClient.new(GA_TRACKING))
      require 'securerandom'
      @session_id = SecureRandom.uuid
      @client = analytics_ingester_client
      @threads = []
    end

    def action_launched(launch_context: nil)
      builder = AnalyticsEventBuilder.new(
        p_hash: launch_context.p_hash,
        session_id: session_id,
        action_name: nil
      )

      launch_event = builder.new_event(:launch)
      post_thread = client.post_event(launch_event)
      unless post_thread.nil?
        @threads << post_thread
      end
    end

    def action_completed(completion_context: nil)
    end

    def finalize_session
      @threads.each do |thread|
        thread.join
      end
    end
  end
end
