module FastlaneCore
  class ToolCollector
    HOST_URL = "https://fastlane-enhancer.herokuapp.com"

    attr_reader :error

    def did_launch_action(name)
      name = name.to_sym
      launches[name] += 1 if is_official?(name)
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

    def is_official?(name)
      return true
    end

    def did_show_message?
      path = File.join(File.expand_path('~'), '.did_show_opt_info')
      did_show = File.exist?(path)
      File.write(path, '1') unless did_show
      did_show
    end
  end
end
