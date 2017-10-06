require 'fastlane_core/analytics/analytics_ingester_client'

module FastlaneCore
  class AnalyticsSession
    attr_accessor :session_id
    attr_accessor :client
    attr_accessor :events
    attr_accessor :ide_version
    attr_accessor :fastfile_id
    attr_accessor :is_fastfile
    alias fastfile? is_fastfile

    # make this a method so that we can override it in monkey patches
    def oauth_app_name
      return 'fastlane'
    end

    def initialize(analytics_ingester_client: AnalyticsIngesterClient.new)
      require 'securerandom'
      @session_id = SecureRandom.uuid
      @client = analytics_ingester_client
      @events = []
    end

    def backfill_p_hashes(p_hash: nil)
      return if p_hash.nil? || @events.count == 0
      @events.reverse_each do |event|
        # event[:actor][:name] is the field in which we store the p_hash
        # to be sent to analytics ingester.
        # If they are nil, we want to fill them in until we reach
        # an event that already has a p_hash.
        @event[:actor][:name].nil? ? @event[:actor][:name] = p_hash : break
      end
    end

    def action_launched(launch_context: nil)
      backfill_p_hashes(p_hash: launch_context.p_hash)

      builder = AnalyticsEventBuilder.new(
        oauth_app_name: oauth_app_name,
        p_hash: launch_context.p_hash,
        session_id: session_id,
        action_name: launch_context.action_name
      )

      @events << builder.launched_event(
        primary_target_hash: {
          name: 'fastlane_version',
          detail: fastlane_version
        }
      )

      @events << builder.launched_event(
        primary_target_hash: {
          name: 'install_method',
          detail: install_method
        }
      )

      @events << builder.launched_event(
        primary_target_hash: {
          name: 'operating_system',
          detail: operating_system
        },
        secondary_target_hash: {
          name: 'version',
          detail: operating_system_version
        }
      )

      @events << builder.launched_event(
        primary_target_hash: {
          name: 'ide_version',
          detail: ide_version
        }
      )

      @events << builder.launched_event(
        primary_target_hash: {
          name: 'ci',
          detail: ci?.to_s
        }
      )

      @events << builder.launched_event(
        primary_target_hash: {
          name: 'fastfile',
          detail: fastfile?.to_s
        },
        secondary_target_hash: {
          name: 'fastfile_id',
          detail: fastfile_id
        }
      )

      @events << builder.launched_event(
        primary_target_hash: {
          name: 'platform',
          detail: launch_context.platform
        }
      )

      @events << builder.launched_event(
        primary_target_hash: {
          name: 'ruby_version',
          detail: ruby_version
        }
      )
    end

    def action_completed(completion_context: nil)
      backfill_p_hashes(p_hash: completion_context.p_hash)

      builder = AnalyticsEventBuilder.new(
        oauth_app_name: oauth_app_name,
        p_hash: completion_context.p_hash,
        session_id: session_id,
        action_name: completion_context.action_name
      )

      @events << builder.completed_event(
        primary_target_hash: {
          name: 'status',
          detail: completion_context.status
        }
      )
    end

    def finalize_session
      # If our users want to opt out of usage metrics, don't post the events.
      # Learn more at https://github.com/fastlane/fastlane#metrics
      return if FastlaneCore::Env.truthy?("FASTLANE_OPT_OUT_USAGE")

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
      return "macOS" if RUBY_PLATFORM.downcase.include?("darwin")
      return "Windows" if RUBY_PLATFORM.downcase.include?("mswin")
      return "Linux" if RUBY_PLATFORM.downcase.include?("linux")
      return "Unknown"
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
      return Helper.is_ci?
    end

    def operating_system_version
      os = self.operating_system
      case os
      when "macOS"
        return `SW_VERS -productVersion`.strip
      else
        # Need to test in Windows and Linux... not sure this is enough
        return Gem::Platform.local.version
      end
    end
  end
end
