module FastlaneCore
  class AnalyticsSession
    attr_accessor :session_id
    attr_accessor :client
    attr_accessor :events

    # make this a method so that we can override it in monkey patches
    def oauth_app_name
      return 'fastlane'
    end

    def initialize(analytics_ingester_client: nil)
      require 'securerandom'
      @session_id = SecureRandom.uuid
      @client = analytics_ingester_client
      @events = []
    end

    def backfill_p_hashes(p_hash: nil)
      return if p_hash.nil? || events.count == 0
      events.reverse_each do |event|
        event[:actor][:name].nil? ? event[:actor][:name] = p_hash : break
      end
    end

    def action_launched(launch_context: nil)
      # TODO:
      # If we have an event in self.events, we'll need to check and see if they have a p_hash, if not, back fill and then advance to the previous event and check again
      # we could get a bunch of actions that don't have app_ids, or app_ids change half-way through
      # eg: action 1, no app_id
      # action 2, app_id (we should backfill action 1 with action 2's app id)
      # action 3, no app_id
      # action 4, different app_id than action 2 (we should backfill action 3 with the new action? I dunno, maybe we don't backfill, but instead, rely on the session_id to tie them together because we can't know which action belongs more closely with what app_id)

      backfill_p_hashes(p_hash: launch_context.p_hash)

      builder = AnalyticsEventBuilder.new(
        oauth_app_name: oauth_app_name,
        p_hash: launch_context.p_hash,
        session_id: session_id,
        action_name: action_launched_context.action_name
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
      # TODO:
      # If we have an event in self.events, we'll need to check and see if they have a p_hash, if not, back fill and then advance to the previous event and check again
      builder = AnalyticsEventBuilder.new(
        oauth_app_name: oauth_app_name,
        p_hash: completion_context.p_hash,
        session_id: session_id,
        action_name: completion_context.action_name
      )
      return events << builder.completed_event(
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
