module FastlaneCore
  class AnalyticsIngesterClient
    def launched_event(session: nil, action_launched_context: nil)
      ingester_events = action_launched_events(
        action_launched_context: action_launched_context,
        session: session
      )

      post_events(events: ingester_events)
    end

    def completed_event(session: nil, action_completed_context: nil)
      ingester_events = action_completed_events(
        action_completed_context: action_completed_context,
        session: session
      )

      post_events(events: ingester_events)
    end

    def post_events(events: nil)
    	# post the events to the endpoint

    end

    def action_completed_events(action_completed_context: nil, session: nil)
      timestamp_millis = Time.now.to_i * 1000
      action_completed_event = {
        event_source: {
          oauth_app_name: session.oauth_app_name,
          product: 'fastlane'
        },
        actor: {
          name: 'p_hash',
          detail: session.p_hash
        },
        action: {
          name: 'completed',
          detail: action_completed_context.action_name
        },
        primary_target: {
          name: 'status',
          detail: action_completed_context.status
        },
        millis_since_epoch: timestamp_millis,
        version: 1
      }

      return [action_completed_event]
    end

    def action_launched_events(action_launched_context: nil, session: nil)
      timestamp_millis = Time.now.to_i * 1000
      launched_event = {
        event_source: {
          oauth_app_name: session.oauth_app_name,
          product: 'fastlane'
        },
        actor: {
          name: 'p_hash',
          detail: session.p_hash
        },
        action: {
          name: 'launched',
          detail: action_launched_context.action_name
        },
        primary_target: {
          name: 'fastlane_version',
          detail: action_launched_context.fastlane_version
        },
        millis_since_epoch: timestamp_millis,
        version: 1
      }

      install_method_event = {
        event_source: {
          oauth_app_name: session.oauth_app_name,
          product: 'fastlane'
        },
        actor: {
          name: 'p_hash',
          detail: session.p_hash
        },
        action: {
          name: 'launched',
          detail: action_launched_context.action_name
        },
        primary_target: {
          name: 'install_method',
          detail: action_launched_context.install_method
        },
        millis_since_epoch: timestamp_millis,
        version: 1
      }

      os_version_event = {
        event_source: {
          oauth_app_name: session.oauth_app_name,
          product: 'fastlane'
        },
        actor: {
          name: 'p_hash',
          detail: session.p_hash
        },
        action: {
          name: 'launched',
          detail: action_launched_context.action_name
        },
        primary_target: {
          name: 'operating_system',
          detail: action_launched_context.operating_system
        },
        secondary_target: {
          name: 'version',
          detail: action_launched_context.operating_system_version
        },
        millis_since_epoch: timestamp_millis,
        version: 1
      }

      ide_version_event = {
        event_source: {
          oauth_app_name: session.oauth_app_name,
          product: 'fastlane'
        },
        actor: {
          name: 'p_hash',
          detail: session.p_hash
        },
        action: {
          name: 'launched',
          detail: action_launched_context.action_name
        },
        primary_target: {
          name: 'ide_version',
          detail: action_launched_context.ide_version
        },
        millis_since_epoch: timestamp_millis,
        version: 1
      }

      ci_event = {
        event_source: {
          oauth_app_name: session.oauth_app_name,
          product: 'fastlane'
        },
        actor: {
          name: 'p_hash',
          detail: session.p_hash
        },
        action: {
          name: 'launched',
          detail: action_launched_context.action_name
        },
        primary_target: {
          name: 'ci',
          detail: action_launched_context.ci
        },
        millis_since_epoch: timestamp_millis,
        version: 1
      }

      fastfile_event = {
        event_source: {
          oauth_app_name: session.oauth_app_name,
          product: 'fastlane'
        },
        actor: {
          name: 'p_hash',
          detail: session.p_hash
        },
        action: {
          name: 'launched',
          detail: action_launched_context.action_name
        },
        primary_target: {
          name: 'fastfile',
          detail: action_launched_context.fastfile
        },
        secondary_target: {
          name: 'fastfile_id',
          detail: action_launched_context.fastfile_id
        },
        millis_since_epoch: timestamp_millis,
        version: 1
      }

      platform_event = {
        event_source: {
          oauth_app_name: session.oauth_app_name,
          product: 'fastlane'
        },
        actor: {
          name: 'p_hash',
          detail: session.p_hash
        },
        action: {
          name: 'launched',
          detail: action_launched_context.action_name
        },
        primary_target: {
          name: 'platform',
          detail: action_launched_context.platform
        },
        millis_since_epoch: timestamp_millis,
        version: 1
      }

      ruby_version_event = {
        event_source: {
          oauth_app_name: session.oauth_app_name,
          product: 'fastlane'
        },
        actor: {
          name: 'p_hash',
          detail: session.p_hash
        },
        action: {
          name: 'launched',
          detail: action_launched_context.action_name
        },
        primary_target: {
          name: 'ruby_version',
          detail: action_launched_context.ruby_version
        },
        millis_since_epoch: timestamp_millis,
        version: 1
      }

      return [
        launched_event,
        install_method_event,
        os_version_event,
        ide_version_event,
        ci_event,
        fastfile_event,
        platform_event,
        ruby_version_event
      ]
    end
  end
end
