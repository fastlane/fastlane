require 'excon'
require 'digest'

require_relative 'changelog'
require_relative '../analytics/app_identifier_guesser'
require_relative '../helper'
require_relative '../ui/ui'

module FastlaneCore
  # Verifies, the user runs the latest version of this gem
  class UpdateChecker
    def self.start_looking_for_update(gem_name)
      return if Helper.test?
      return if FastlaneCore::Env.truthy?("FASTLANE_SKIP_UPDATE_CHECK")

      @start_time = Time.now

      Thread.new do
        begin
          send_launch_analytic_events_for(gem_name)
        rescue
          # we don't want to show a stack trace if something goes wrong
        end
      end

      Thread.new do
        begin
          server_results[gem_name] = fetch_latest(gem_name)
        rescue
          # we don't want to show a stack trace if something goes wrong
        end
      end
    end

    def self.server_results
      @results ||= {}
    end

    class << self
      attr_reader :start_time
    end

    def self.update_available?(gem_name, current_version)
      latest = server_results[gem_name]
      return (latest and Gem::Version.new(latest) > Gem::Version.new(current_version))
    end

    def self.show_update_status(gem_name, current_version)
      Thread.new do
        begin
          send_completion_events_for(gem_name)
        rescue
          # we don't want to show a stack trace if something goes wrong
        end
      end

      if update_available?(gem_name, current_version)
        show_update_message(gem_name, current_version)
      end
    end

    # Show a message to the user to update to a new version of fastlane (or a sub-gem)
    # Use this method, as this will detect the current Ruby environment and show an
    # appropriate message to the user
    def self.show_update_message(gem_name, current_version)
      available = server_results[gem_name]
      puts("")
      puts('#######################################################################')
      if available
        puts("# #{gem_name} #{available} is available. You are on #{current_version}.")
      else
        puts("# An update for #{gem_name} is available. You are on #{current_version}.")
      end
      puts("# You should use the latest version.")
      puts("# Please update using `#{self.update_command(gem_name: gem_name)}`.")

      puts("# To see what's new, open https://github.com/fastlane/#{gem_name}/releases.") if FastlaneCore::Env.truthy?("FASTLANE_HIDE_CHANGELOG")

      if !Helper.bundler? && !Helper.contained_fastlane? && Random.rand(5) == 1
        # We want to show this message from time to time, if the user doesn't use bundler, nor bundled fastlane
        puts('#######################################################################')
        puts("# Run `sudo gem cleanup` from time to time to speed up fastlane")
      end
      puts('#######################################################################')
      Changelog.show_changes(gem_name, current_version, update_gem_command: UpdateChecker.update_command(gem_name: gem_name)) unless FastlaneCore::Env.truthy?("FASTLANE_HIDE_CHANGELOG")

      ensure_rubygems_source
    end

    # The command that the user should use to update their mac
    def self.update_command(gem_name: "fastlane")
      if Helper.bundler?
        "bundle update #{gem_name.downcase}"
      elsif Helper.contained_fastlane? || Helper.homebrew?
        "fastlane update_fastlane"
      elsif Helper.mac_app?
        "the Fabric app. Launch the app and navigate to the fastlane tab to get the most recent version."
      else
        "sudo gem install #{gem_name.downcase}"
      end
    end

    # Check if RubyGems is set as a gem source
    # on some machines that might not be the case
    # and then users can't find the update when
    # running the specified command
    def self.ensure_rubygems_source
      return if Helper.contained_fastlane?
      return if `gem sources`.include?("https://rubygems.org")
      puts("")
      UI.error("RubyGems is not listed as your Gem source")
      UI.error("You can run `gem sources` to see all your sources")
      UI.error("Please run the following command to fix this:")
      UI.command("gem sources --add https://rubygems.org")
    end

    def self.fetch_latest(gem_name)
      JSON.parse(Excon.get(generate_fetch_url(gem_name)).body)["version"]
    end

    def self.generate_fetch_url(gem_name)
      "https://rubygems.org/api/v1/gems/#{gem_name}.json"
    end

    def self.send_launch_analytic_events_for(gem_name)
      return if FastlaneCore::Env.truthy?("FASTLANE_OPT_OUT_USAGE")
      ci = Helper.ci?.to_s
      app_id_guesser = FastlaneCore::AppIdentifierGuesser.new(args: ARGV, gem_name: gem_name)
      project_hash = app_id_guesser.p_hash
      p_hash = project_hash if project_hash
      platform = @platform if @platform # this has to be called after `p_hash`

      send_launch_analytic_events(p_hash, gem_name, platform, ci)
    end

    def self.send_launch_analytic_events(p_hash, tool, platform, ci)
      timestamp_seconds = Time.now.to_i

      analytics = []
      analytics << event_for_p_hash(p_hash, tool, platform, timestamp_seconds) if p_hash
      analytics << event_for_launch(tool, ci, timestamp_seconds)

      send_events(analytics)
    end

    def self.event_for_p_hash(p_hash, tool, platform, timestamp_seconds)
      {
        event_source: {
          oauth_app_name: oauth_app_name,
          product: 'fastlane'
        },
        actor: {
          name: 'project',
          detail: p_hash
        },
        action: {
          name: 'update_checked'
        },
        primary_target: {
          name: 'tool',
          detail: tool || 'unknown'
        },
        secondary_target: {
          name: 'platform',
          detail: secondary_target_string(platform || 'unknown')
        },
        millis_since_epoch: timestamp_seconds * 1000,
        version: 1
      }
    end

    def self.event_for_launch(tool, ci, timestamp_seconds)
      {
        event_source: {
          oauth_app_name: oauth_app_name,
          product: 'fastlane'
        },
        actor: {
          name: 'tool',
          detail: tool || 'unknown'
        },
        action: {
          name: 'launched'
        },
        primary_target: {
          name: 'ci',
          detail: ci
        },
        secondary_target: {
          name: 'launch',
          detail: secondary_target_string('')
        },
        millis_since_epoch: timestamp_seconds * 1000,
        version: 1
      }
    end

    def self.send_completion_events_for(gem_name)
      return if FastlaneCore::Env.truthy?("FASTLANE_OPT_OUT_USAGE")

      ci = Helper.ci?.to_s
      install_method = if Helper.rubygems?
                         'gem'
                       elsif Helper.bundler?
                         'bundler'
                       elsif Helper.mac_app?
                         'mac_app'
                       elsif Helper.contained_fastlane?
                         'standalone'
                       elsif Helper.homebrew?
                         'homebrew'
                       else
                         'unknown'
                       end
      duration = (Time.now - start_time).to_i
      timestamp_seconds = Time.now.to_i

      send_completion_events(gem_name, ci, install_method, duration, timestamp_seconds)
    end

    def self.send_events(analytics)
      analytic_event_body = { analytics: analytics }.to_json

      url = ENV["FASTLANE_METRICS_URL"] || "https://fastlane-metrics.fabric.io/public"
      Excon.post(url,
                 body: analytic_event_body,
                 headers: { "Content-Type" => 'application/json' })
    end

    def self.event_for_completion(tool, ci, duration, timestamp_seconds)
      {
        event_source: {
          oauth_app_name: oauth_app_name,
          product: 'fastlane'
        },
        actor: {
          name: 'tool',
          detail: tool || 'unknown'
        },
        action: {
          name: 'completed_with_duration'
        },
        primary_target: {
          name: 'duration',
          detail: duration.to_s
        },
        secondary_target: {
          name: 'ci',
          detail: secondary_target_string(ci)
        },
        millis_since_epoch: timestamp_seconds * 1000,
        version: 1
      }
    end

    def self.event_for_install_method(tool, ci, install_method, timestamp_seconds)
      {
        event_source: {
          oauth_app_name: oauth_app_name,
          product: 'fastlane'
        },
        actor: {
          name: 'tool',
          detail: tool || 'unknown'
        },
        action: {
          name: 'completed_with_install_method'
        },
        primary_target: {
          name: 'install_method',
          detail: install_method
        },
        secondary_target: {
          name: 'ci',
          detail: secondary_target_string(ci)
        },
        millis_since_epoch: timestamp_seconds * 1000,
        version: 1
      }
    end

    def self.secondary_target_string(string)
      return string
    end

    def self.oauth_app_name
      return 'fastlane-refresher'
    end

    def self.send_completion_events(tool, ci, install_method, duration, timestamp_seconds)
      analytics = []
      analytics << event_for_completion(tool, ci, duration, timestamp_seconds)
      analytics << event_for_install_method(tool, ci, install_method, timestamp_seconds)

      send_events(analytics)
    end
  end
end
