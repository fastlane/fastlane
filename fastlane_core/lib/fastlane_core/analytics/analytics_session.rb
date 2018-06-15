require_relative 'analytics_ingester_client'
require_relative 'action_launch_context'
require_relative 'analytics_event_builder'

module FastlaneCore
  class AnalyticsSession
    attr_accessor :session_id
    attr_accessor :client
    attr_accessor :events
    attr_accessor :is_fastfile
    alias fastfile? is_fastfile

    def initialize(analytics_ingester_client: AnalyticsIngesterClient.new)
      require 'securerandom'
      @session_id = SecureRandom.uuid
      @client = analytics_ingester_client
      @events = []
      @is_fastfile = false
    end

    def opt_out_metrics?
      FastlaneCore::Env.truthy?("FASTLANE_OPT_OUT_USAGE")
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

    def is_fastfile=(value)
      if value
        # If true, update all of the events to reflect
        # that the execution is running within a Fastfile context.
        # We don't want to update if this is false because once we
        # detect a true value, that is the one to be trusted
        @events.reverse_each do |event|
          # Follow-up: decide whether we need this
          # event[:primary_target][:name] == 'fastfile' ? event[:primary_target][:detail] = value.to_s : next
        end
      end
      @is_fastfile = value
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
      # If our users want to opt out of usage metrics, don't post the events.
      # Learn more at https://docs.fastlane.tools/#metrics
      return if opt_out_metrics?

      client.post_events(@events)
    end

    def fastlane_version
      return Fastlane::VERSION
    end

    def ruby_version
      patch_level = RUBY_PATCHLEVEL == 0 ? nil : "p#{RUBY_PATCHLEVEL}"
      return "#{RUBY_VERSION}#{patch_level}"
    end

    def operating_system
      return Helper.operating_system
    end

    def install_method
      if Helper.rubygems?
        return 'gem'
      elsif Helper.bundler?
        return 'bundler'
      elsif Helper.mac_app?
        return 'mac_app'
      elsif Helper.contained_fastlane?
        return 'standalone'
      elsif Helper.homebrew?
        return 'homebrew'
      else
        return 'unknown'
      end
    end

    def ci?
      return Helper.ci?
    end

    def operating_system_version
      os = self.operating_system
      case os
      when "macOS"
        return system('sw_vers', out: File::NULL) ? `sw_vers -productVersion`.strip : 'unknown'
      else
        # Need to test in Windows and Linux... not sure this is enough
        return Gem::Platform.local.version
      end
    end
  end
end
