module FastlaneCore
  class AnalyticsSession
    attr_accessor :p_hash
    attr_accessor :session_id
    attr_accessor :client
    attr_accessor :events

    # make this a method so that we can override it in monkey patches
    def oauth_app_name
      return 'fastlane'
    end

    def initialize(p_hash: nil, analytics_ingester_client: nil)
      @p_hash = p_hash
      @client = analytics_ingester_client
      @events = []
    end

    def action_launched(launch_context: nil)
      builder = AnalyticsEventBuilder.new(
        oauth_app_name: oauth_app_name,
        p_hash: p_hash,
        session_id: session_id,
        action_name: action_launched_context.action_name,
        timestamp_millis: Time.now.to_i * 1000
      )

      version_event = builder.launched_event(
        primary_target_hash: {
          name: 'fastlane_version',
          detail: action_launched_context.fastlane_version
        }
      )

      install_method_event = builder.launched_event(
        primary_target_hash: {
          name: 'install_method',
          detail: action_launched_context.install_method
        }
      )

      os_version_event = builder.launched_event(
        primary_target_hash: {
          name: 'operating_system',
          detail: action_launched_context.operating_system
        },
        secondary_target_hash: {
          name: 'version',
          detail: action_launched_context.operating_system_version
        }
      )

      ide_version_event = builder.launched_event(
        primary_target_hash: {
          name: 'ide_version',
          detail: action_launched_context.ide_version
        }
      )

      ci_event = builder.launched_event(
        primary_target_hash: {
          name: 'ci',
          detail: action_launched_context.ci
        }
      )

      fastfile_event = builder.launched_event(
        primary_target_hash: {
          name: 'fastfile',
          detail: action_launched_context.fastfile
        },
        secondary_target_hash: {
          name: 'fastfile_id',
          detail: action_launched_context.fastfile_id
        }
      )

      platform_event = builder.launched_event(
        primary_target_hash: {
          name: 'platform',
          detail: action_launched_context.platform
        }
      )

      ruby_version_event = builder.launched_event(
        primary_target_hash: {
          name: 'ruby_version',
          detail: action_launched_context.ruby_version
        }
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
        oauth_app_name: oauth_app_name,
        p_hash: p_hash,
        session_id: session_id,
        action_name: completion_context.action_name,
        timestamp_millis: Time.now.to_i * 1000
      )
      return events + builder.completed_event(
        primary_target_hash: {
          name: 'status',
          detail: completion_context.status
        }
      )
    end

    def finalize_session
      client.post_events(events)
    end
  end
end
