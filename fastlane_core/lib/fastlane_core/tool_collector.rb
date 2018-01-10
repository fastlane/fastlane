require_relative 'helper'

module FastlaneCore
  class ToolCollector
    # Learn more at https://docs.fastlane.tools/#metrics

    # This is the original error reporting mechanism, which has always represented
    # either controlled (UI.user_error!), or uncontrolled (UI.crash!, anything else)
    # exceptions.
    #
    # Thus, if you call `did_crash`, it will record the failure both here, and in the
    # newer, more specific `crash` field.
    #
    # This value is a String, which is the name of the tool that caused the error
    attr_reader :error

    # This is the newer field for tracking only uncontrolled exceptions.
    #
    # This is written to only when `did_crash` is called, and therefore excludes
    # controlled exceptions.
    #
    # This value is a boolean, which is true if the error was an uncontrolled exception
    attr_reader :crash

    def initialize
      @crash = false
    end

    def did_launch_action(name)
      name = name_to_track(name.to_sym)
      return unless name

      launches[name] += 1
      versions[name] ||= determine_version(name)
    end

    # Call when the problem is a caught/controlled exception (e.g. via UI.user_error!)
    def did_raise_error(name)
      name = name_to_track(name.to_sym)
      return unless name

      @error = name
      # Don't write to the @crash field so that we can distinguish this exception later
      # as being controlled
    end

    # Call when the problem is an uncaught/uncontrolled exception (e.g. via UI.crash!)
    def did_crash(name)
      name = name_to_track(name.to_sym)
      return unless name

      # Write to the @error field to maintain the historical behavior of the field, so
      # that the server gets the same data in that field from old and new clients
      @error = name
      # Also specifically note that this exception was uncontrolled in the @crash field
      @crash = true
    end

    def did_finish
      return false if FastlaneCore::Env.truthy?("FASTLANE_OPT_OUT_USAGE")

      if !did_show_message? && !Helper.ci?
        show_message
      end

      require 'excon'
      url = ENV["FASTLANE_METRICS_URL"] || "https://fastlane-metrics.fabric.io/public"

      analytic_event_body = create_analytic_event_body

      # Never generate web requests during tests
      unless Helper.test?
        Thread.new do
          begin
            Excon.post(url,
                       body: analytic_event_body,
                       headers: { "Content-Type" => 'application/json' })
          rescue
            # we don't want to show a stack trace if something goes wrong
          end
        end
      end

      return true
    rescue
      # We don't care about connection errors
    end

    def create_analytic_event_body
      analytics = []
      timestamp_seconds = Time.now.to_i

      # `fastfile_id` helps us track success/failure metrics for Fastfiles we
      # generate as part of an automated process.
      fastfile_id = ENV["GENERATED_FASTFILE_ID"]

      if fastfile_id && launches.size == 1 && launches['fastlane']
        if crash
          completion_status = 'crash'
        elsif error
          completion_status = 'error'
        else
          completion_status = 'success'
        end
        analytics << event_for_web_onboarding(fastfile_id, completion_status, timestamp_seconds)
      end

      launches.each do |action, count|
        action_version = versions[action] || 'unknown'
        if crash && error == action
          action_completion_status = 'crash'
        elsif action == error
          action_completion_status = 'error'
        else
          action_completion_status = 'success'
        end
        analytics << event_for_completion(action, action_completion_status, action_version, timestamp_seconds)
        analytics << event_for_count(action, count, action_version, timestamp_seconds)
      end
      { analytics: analytics }.to_json
    end

    def show_message
      UI.message("Sending Crash/Success information")
      UI.message("Learn more at https://docs.fastlane.tools/#metrics")
      UI.message("No personal/sensitive data is sent. Only sharing the following:")
      UI.message(launches)
      UI.message(@error) if @error
      UI.message("This information is used to fix failing tools and improve those that are most often used.")
      UI.message("You can disable this by adding `opt_out_usage` at the top of your Fastfile")
    end

    def launches
      @launches ||= Hash.new(0)
    end

    # Maintains a hash of tool names to their detected versions.
    #
    # This data is sent in the same manner as launches, as an inline form-encoded JSON value in the POST.
    # For example:
    #
    # {
    #   match: '0.5.0',
    #   fastlane: '1.86.1'
    # }
    def versions
      @versions ||= {}
    end

    # Override this in subclasses
    def is_official?(name)
      return true
    end

    # Returns nil if we shouldn't track this action
    # Returns a (maybe modified) name that should be sent to the analytic ingester
    # Modificiation is used to prefix the action name with the name of the plugin
    def name_to_track(name)
      return nil unless is_official?(name)
      name
    end

    def did_show_message?
      file_name = ".did_show_opt_info"

      legacy_path = File.join(File.expand_path('~'), file_name)
      new_path = File.join(FastlaneCore.fastlane_user_dir, file_name)
      did_show = File.exist?(new_path) || File.exist?(legacy_path)

      return did_show if did_show

      File.write(new_path, '1')
      false
    end

    def determine_version(name)
      self.class.determine_version(name)
    end

    def self.determine_version(name)
      unless name.to_s.start_with?("fastlane-plugin")
        # In the early days before the mono gem this was more complicated
        # Now we have a mono version number, which makes this method easy
        # for all built-in actions and tools
        require 'fastlane/version'
        return Fastlane::VERSION
      end

      # For plugins we still need to load the specific version
      begin
        name = name.to_s.downcase

        # We need to pre-load the version file because tools that are invoked through their actions
        # will not yet have run their action, and thus will not yet have loaded the file which defines
        # the module and constant we need.
        require File.join(name, "version")

        # Go from :foo_bar to 'FooBar'
        module_name = name.fastlane_module

        # Look up the VERSION constant defined for the given tool name,
        # or return 'unknown' if we can't find it where we'd expect
        if Kernel.const_defined?(module_name)
          tool_module = Kernel.const_get(module_name)

          if tool_module.const_defined?('VERSION')
            return tool_module.const_get('VERSION')
          end
        end
      rescue LoadError
        # If there is no version file to load, this is not a tool for which
        # we can report a particular version
      end

      return nil
    end

    def event_for_web_onboarding(fastfile_id, completion_status, timestamp_seconds)
      {
        event_source: {
          oauth_app_name: oauth_app_name,
          product: 'fastlane_web_onboarding'
        },
        actor: {
          name: 'customer',
          detail: fastfile_id
        },
        action: {
          name: 'fastfile_executed'
        },
        primary_target: {
          name: 'fastlane_completion_status',
          detail: completion_status
        },
        secondary_target: {
          name: 'executed',
          detail: secondary_target_string('')
        },
        millis_since_epoch: timestamp_seconds * 1000,
        version: 1
      }
    end

    def event_for_completion(action, completion_status, version, timestamp_seconds)
      {
        event_source: {
          oauth_app_name: oauth_app_name,
          product: 'fastlane'
        },
        actor: {
          name: 'action',
          detail: action
        },
        action: {
          name: 'execution_completed'
        },
        primary_target: {
          name: 'completion_status',
          detail: completion_status
        },
        secondary_target: {
          name: 'version',
          detail: secondary_target_string(version)
        },
        millis_since_epoch: timestamp_seconds * 1000,
        version: 1
      }
    end

    def event_for_count(action, count, version, timestamp_seconds)
      {
        event_source: {
          oauth_app_name: oauth_app_name,
          product: 'fastlane'
        },
        actor: {
          name: 'action',
          detail: action
        },
        action: {
          name: 'execution_counted'
        },
        primary_target: {
          name: 'count',
          detail: count.to_s || "1"
        },
        secondary_target: {
          name: 'version',
          detail: secondary_target_string(version)
        },
        millis_since_epoch: timestamp_seconds * 1000,
        version: 1
      }
    end

    def oauth_app_name
      return 'fastlane-enhancer'
    end

    def secondary_target_string(string)
      return string
    end
  end
end
