require_relative 'analytics_ingester_client'
require_relative 'action_launch_context'
require_relative 'analytics_event_builder'

module FastlaneCore
  class AnalyticsSession
    GA_TRACKING = "UA-121171860-1"

    private_constant :GA_TRACKING
    attr_accessor :session_id
    attr_accessor :client
    attr_accessor :events

    def initialize(analytics_ingester_client: AnalyticsIngesterClient.new(GA_TRACKING))
      require 'securerandom'
      @session_id = SecureRandom.uuid
      @client = analytics_ingester_client
      @events = []
    end

    def backfill_p_hashes(p_hash: nil)
      return if p_hash.nil? || p_hash == ActionLaunchContext::UNKNOWN_P_HASH || @events.count == 0
      @events.reverse_each do |event|
        # event[:actor][:name] is the field in which we store the p_hash
        # to be sent to analytics ingester.
        # If they are nil, we want to fill them in until we reach
        # an event that already has a p_hash.
        if event[:p_hash].nil? || event[:p_hash] == ActionLaunchContext::UNKNOWN_P_HASH
          event[:p_hash] = p_hash
        else
          break
        end
      end
    end

    def action_launched(launch_context: nil)
      backfill_p_hashes(p_hash: launch_context.p_hash)

      builder = AnalyticsEventBuilder.new(
        p_hash: launch_context.p_hash,
        session_id: session_id,
        action_name: nil
      )

      launch_events = [builder.new_event(:launch)]
      client.post_events(launch_events)
    end

    def action_completed(completion_context: nil)
    end

    def finalize_session
    end
  end
end
