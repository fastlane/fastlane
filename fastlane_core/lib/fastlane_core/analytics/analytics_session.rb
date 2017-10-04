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

      version_event = builder.launched_event(
        primary_target_hash: {
          name: 'fastlane_version',
          detail: action_launched_context.fastlane_version
        },
        timestamp_millis: timestamp_millis
      )

      install_method_event = builder.launched_event(
        primary_target_hash: {
          name: 'install_method',
          detail: action_launched_context.install_method
        },
        timestamp_millis: timestamp_millis
      )

      os_version_event = builder.launched_event(
        primary_target_hash: {
          name: 'operating_system',
          detail: action_launched_context.operating_system
        },
        secondary_target_hash: {
          name: 'version',
          detail: action_launched_context.operating_system_version
        },
        timestamp_millis: timestamp_millis
      )

      ide_version_event = builder.launched_event(
        primary_target_hash: {
          name: 'ide_version',
          detail: action_launched_context.ide_version
        },
        timestamp_millis: timestamp_millis
      )

      ci_event = builder.launched_event(
        primary_target_hash: {
          name: 'ci',
          detail: action_launched_context.ci
        },
        timestamp_millis: timestamp_millis
      )

      fastfile_event = builder.launched_event(
        primary_target_hash: {
          name: 'fastfile',
          detail: action_launched_context.fastfile
        },
        secondary_target_hash: {
          name: 'fastfile_id',
          detail: action_launched_context.fastfile_id
        },
        timestamp_millis: timestamp_millis
      )

      platform_event = builder.launched_event(
        primary_target_hash: {
          name: 'platform',
          detail: action_launched_context.platform
        },
        timestamp_millis: timestamp_millis
      )

      ruby_version_event = builder.launched_event(
        primary_target_hash: {
          name: 'ruby_version',
          detail: action_launched_context.ruby_version
        },
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
        primary_target_hash: {
          name: 'status',
          detail: completion_context.status
        },
        timestamp: Time.now.to_i * 1000
      )
    end

    def finalize_session
      client.post_events(events)
    end
  end
end
