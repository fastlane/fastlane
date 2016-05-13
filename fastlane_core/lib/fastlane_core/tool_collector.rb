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
      name = name.to_sym

      if is_official?(name)
        launches[name] += 1
        versions[name] ||= determine_version(name)
      end
    end

    # Call when the problem is a caught/controlled exception (e.g. via UI.user_error!)
    def did_raise_error(name)
      name = name.to_sym
      if is_official?(name)
        @error = name
        # Don't write to the @crash field so that we can distinguish this exception later
        # as being controlled
      end
    end

    # Call when the problem is an uncaught/uncontrolled exception (e.g. via UI.crash!)
    def did_crash(name)
      name = name.to_sym
      if is_official?(name)
        # Write to the @error field to maintain the historical behavior of the field, so
        # that the server gets the same data in that field from old and new clients
        @error = name
        # Also specifically note that this exception was uncontrolled in the @crash field
        @crash = true
      end
    end

    def did_finish
      return false if ENV["FASTLANE_OPT_OUT_USAGE"]

      if !did_show_message? and !Helper.is_ci?
        show_message
      end

      require 'excon'
      url = HOST_URL + '/did_launch?'
      url += URI.encode_www_form(
        versions: versions.to_json,
        steps: launches.to_json,
        error: @error,
        crash: @crash ? @error : nil
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

    def is_official?(name)
      return true
    end

    def did_show_message?
      path = File.join(File.expand_path('~'), '.did_show_opt_info')
      did_show = File.exist?(path)
      File.write(path, '1') unless did_show
      did_show
    end

    def determine_version(name)
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
