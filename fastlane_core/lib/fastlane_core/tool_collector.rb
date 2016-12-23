module FastlaneCore
  class ToolCollector
    HOST_URL = ENV['FASTLANE_ENHANCER_URL'] || "https://fastlane-enhancer.herokuapp.com"

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

      if !did_show_message? and !Helper.is_ci?
        show_message
      end

      # `fastfile_id` helps us track success/failure metrics for Fastfiles we
      # generate as part of an automated process.
      require 'excon'
      url = HOST_URL + '/did_launch?'
      url += URI.encode_www_form(
        versions: versions.to_json,
        steps: launches.to_json,
        error: @error || "",
        crash: @crash ? @error : "",
        fastfile_id: ENV["GENERATED_FASTFILE_ID"] || ""
      )

      if Helper.is_test? # don't send test data
        return url
      else
        fork do
          begin
            Excon.post(url)
          rescue
            # we don't want to show a stack trace if something goes wrong
          end
        end
        return true
      end
    rescue
      # We don't care about connection errors
    end

    def show_message
      UI.message("Sending Crash/Success information. More information on: https://github.com/fastlane/enhancer")
      UI.message("No personal/sensitive data is sent. Only sharing the following:")
      UI.message(launches)
      UI.message(@error) if @error
      UI.message("This information is used to fix failing tools and improve those that are most often used.")
      UI.message("You can disable this by setting the environment variable: FASTLANE_OPT_OUT_USAGE=1")
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
    # Returns a (maybe modified) name that should be sent to the enhancer web service
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
      require 'fastlane'
      return Fastlane::VERSION if Fastlane::ActionsList.find_action_named(name.to_s)

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
  end
end
