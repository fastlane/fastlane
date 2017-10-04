module FastlaneCore
  class AnalyticsEventBuilder
    attr_accessor :base_launch_hash
    attr_accessor :base_completion_hash

    def initialize(oauth_app_name: nil, p_hash: nil, session_id: nil, action_name: nil)
      @base_launch_hash = {
        event_source: {
          oauth_app_name: oauth_app_name,
          product: 'fastlane'
        },
        actor: {
          name: p_hash,
          detail: session_id
        },
        action: {
          name: 'launched',
          detail: action_name
        },
        version: 1
      }

      @base_completion_hash = {
        event_source: {
          oauth_app_name: oauth_app_name,
          product: 'fastlane'
        },
        actor: {
          name: p_hash,
          detail: session_id
        },
        action: {
          name: 'completed',
          detail: action_name
        },
        version: 1
      }
    end

    def new_event(primary_target_hash: nil, secondary_target_hash: nil, timestamp_millis: nil)
      raise 'Need timestamp_millis' if timestamp_millis.nil?
      raise 'Need at least a primary_target_hash' if primary_target_hash.nil?
      event = base_launch_hash.dup
      event[:primary_target] = primary_target_hash
      event[:secondary_target] = secondary_target_hash unless secondary_target_hash.nil?
      event[:millis_since_epoch] = timestamp_millis
      return event
    end

    def completed_event(status: nil, timestamp: nil)
      completed_event = base_completion_hash.dup
      completed_event[:primary_target] = {
        name: 'status',
        detail: status
      }
      completed_event[:millis_since_epoch] = timestamp
      return completed_event
    end
  end
end
