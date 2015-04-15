module Fastlane
  class ActionCollector
    HOST_URL = "https://fastlane-enhancer.herokuapp.com/"

    def did_launch_action(name)
      launches[name] ||= 0
      launches[name] += 1
    end

    def did_raise_error(name)
      @error = name
    end

    # Sends the used actions
    # Example data => [:xcode_select, :deliver, :notify, :slack]
    def did_finish
      Thread.new do
        unless ENV["FASTLANE_OPT_OUT_USAGE"]
          
          unless did_show_message?
            Helper.log.debug("Sending Crash/Success information. More information on: https://github.com/fastlane/enhancer")
            Helper.log.debug("No personal/sensitive data is sent. Only sharing the following:")
            Helper.log.debug(launches)
            Helper.log.debug(@error) if @error
            Helper.log.debug("This information is used to fix failing actions and improve integrations that are often used.")
            Helper.log.debug("You can disable this by adding `opt_out_usage` to your Fastfile")
          end

          require 'excon'
          url = HOST_URL + '/did_launch?'
          url += URI.encode_www_form(
                  steps: launches.to_json,
                  error: @error
                )

          Excon.post(url)
        end
      end
    end

    def launches
      @launches ||= {}
    end

    def did_show_message?
      path = File.join(File.expand_path('~'), '.did_show_opt_info')
      
      did_show = File.exists?path
      File.write(path, '1')
      did_show
    end
  end
end