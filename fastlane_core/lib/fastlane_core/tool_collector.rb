module FastlaneCore
  class ToolCollector
    HOST_URL = "http://localhost:3000"

    attr_reader :error

    def did_launch_action(name)
      name = name.to_sym

      if is_official?(name)
        launches[name] += 1
        versions[name] ||= determine_version(name)
      end
    end

    def did_raise_error(name)
      name = name.to_sym
      @error = name if is_official?(name)
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
        error: @error
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
        # We need to pre-load the version file because tools that are invoked through their actions
        # will not yet have run their action, and thus will not yet have loaded the file which defines
        # the module and constant we need.
        require "#{name}/version"

        # Go from :credentials_manager to 'CredentialsManager'
        class_name = name.to_s.fastlane_class

        # Look up the VERSION constant defined for the given tool name,
        # or return 'unknown' if we can't find it where we'd expect
        if Kernel.const_defined?(class_name)
          tool_module = Kernel.const_get(class_name)

          if tool_module.const_defined?('VERSION')
            return tool_module.const_get('VERSION')
          end
        end
      rescue LoadError
        # If there is no version file to load, this is not a tool for which
        # we can report a particular version
      end

      return 'unknown'
    end
  end
end
