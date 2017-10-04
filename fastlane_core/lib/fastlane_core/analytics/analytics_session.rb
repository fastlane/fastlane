module FastlaneCore
  class AnalyticsSession
    attr_accessor :p_hash
    attr_accessor :session_id
    attr_accessor :client
    attr_accessor :events

    def initialize(p_hash: nil, analytics_ingester_client: nil)
      @p_hash = p_hash
      @client = analytics_ingester_client
      @events = []
    end

    def action_launched(launch_context: nil)
      builder = AnalyticsEventBuilder.new(
        oauth_app_name: session.oauth_app_name,
        p_hash: session.p_hash,
        session_id: session.session_id,
        action_name: action_launched_context.action_name
      )

      timestamp_millis = Time.now.to_i * 1000

      version_event = builder.fastlane_version_launched_event(
        fastlane_version: action_launched_context.fastlane_version,
        timestamp: timestamp_millis
      )

      install_method_event = builder.install_method_launched_event(
        install_method: action_launched_context.install_method,
        timestamp: timestamp_millis
      )

      os_version_event = builder.os_version_launched_event(
        operating_system: action_launched_context.operating_system,
        version: action_launched_context.operating_system_version,
        timestamp: timestamp_millis
      )

      ide_version_event = builder.ide_version_launched_event(
        ide_version: action_launched_context.ide_version,
        timestamp: timestamp_millis
      )

      ci_event = builder.ci_launched_event(
        ci: action_launched_context.ci,
        timestamp: timestamp_millis
      )

      fastfile_event = builder.fastfile_launched_event(
        fastfile: action_launched_context.fastfile,
        fastfile_id: action_launched_context.fastfile_id,
        timestamp: timestamp_millis
      )

      platform_event = builder.platform_launched_event(
        platform: action_launched_context.platform,
        timestamp: timestamp_millis
      )

      ruby_version_details = {
        name: 'ruby_version',
        detail: action_launched_context.ruby_version
      }

      ruby_version_event = builder.new_event(
        event_key: :primary_target,
        event_dictionary: ruby_version_details,
        timestamp_millis: timestamp_millis
      )

      return events + [
        version_event,
        install_method_event,
        os_version_event,
        ide_version_event,
        ci_event,
        fastfile_event,
        platform_event,
        ruby_version_event
      ]
    end

    def action_completed(completion_context: nil)
      builder = AnalyticsEventBuilder.new(
        oauth_app_name: session.oauth_app_name,
        p_hash: session.p_hash,
        session_id: session.session_id,
        action_name: completion_context.action_name
      )
      return events + builder.completed_event(
        status: completion_context.status,
        timestamp: Time.now.to_i * 1000
      )
    end

    def finalize_session
      client.post_events(events)
    end
  end
end
