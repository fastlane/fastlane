module FastlaneCore
  class AnalyticsEventBuilder
    attr_accessor :base_hash

    def initialize(oauth_app_name: nil, p_hash: nil, session_id: nil, action_name: nil)
      @base_hash = {
        event_source: {
          oauth_app_name: oauth_app_name,
          product: 'fastlane'
        },
        actor: {
          name: p_hash,
          detail: session_id
        },
        version: 1
      }
    end

    def launched_event(primary_target_hash: nil, secondary_target_hash: nil, timestamp_millis: nil)
      return new_event(
        stage: 'launched',
        primary_target_hash: primary_target_hash,
        secondary_target_hash: secondary_target_hash,
        timestamp_millis: timestamp_millis
      )
    end

    def completed_event(primary_target_hash: nil, secondary_target_hash: nil, timestamp_millis: nil)
      return new_event(
        stage: 'completed',
        primary_target_hash: primary_target_hash,
        secondary_target_hash: secondary_target_hash,
        timestamp_millis: timestamp_millis
      )
    end

    def new_event(stage: nil, primary_target_hash: nil, secondary_target_hash: nil, timestamp_millis: nil)
      raise 'Need timestamp_millis' if timestamp_millis.nil?
      raise 'Need at least a primary_target_hash' if primary_target_hash.nil?
      event = base_hash.dup
      event[:action] = {
          name: stage,
          detail: action_name
      }
      event[:primary_target] = primary_target_hash
      event[:secondary_target] = secondary_target_hash unless secondary_target_hash.nil?
      event[:millis_since_epoch] = timestamp_millis
      return event
    end
  end
end
