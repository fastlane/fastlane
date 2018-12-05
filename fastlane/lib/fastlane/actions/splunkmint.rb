module Fastlane
  module Actions
    class SplunkmintAction < Action
      def self.run(params)
        command = []
        command << "curl"
        command << verbose(params)
        command += proxy_options(params)
        command += upload_options(params)
        command << upload_url
        command << upload_progress(params)

        # Fastlane::Actions.sh has buffering issues, no progress bar is shown in real time
        # will reanable it when it is fixed
        # result = Fastlane::Actions.sh(command.join(' '), log: false)
        shell_command = command.join(' ')
        result = Helper.test? ? shell_command : `#{shell_command}`
        fail_on_error(result)

        result
      end

      def self.fail_on_error(result)
        if result.include?("error")
          UI.user_error!("Server error, failed to upload the dSYM file")
        end
      end

      def self.upload_url
        "https://ios.splkmobile.com/api/v1/dsyms/upload"
      end

      def self.verbose(params)
        params[:verbose] ? "--verbose" : ""
      end

      def self.upload_progress(params)
        params[:upload_progress] ? " --progress-bar -o /dev/null --no-buffer" : ""
      end

      def self.dsym_path(params)
        file_path = params[:dsym]
        file_path ||= Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH] || ENV[SharedValues::DSYM_OUTPUT_PATH.to_s]
        file_path ||= Actions.lane_context[SharedValues::DSYM_ZIP_PATH] || ENV[SharedValues::DSYM_ZIP_PATH.to_s]

        if file_path
          expanded_file_path = File.expand_path(file_path)
          UI.user_error!("Couldn't find file at path '#{expanded_file_path}'") unless File.exist?(expanded_file_path)

          return expanded_file_path
        else
          UI.user_error!("Couldn't find any dSYM file")
        end
      end

      def self.upload_options(params)
        file_path = dsym_path(params).shellescape

        options = []
        options << "-F file=@#{file_path}"
        options << "--header 'X-Splunk-Mint-Auth-Token: #{params[:api_token].shellescape}'"
        options << "--header 'X-Splunk-Mint-apikey: #{params[:api_key].shellescape}'"

        options
      end

      def self.proxy_options(params)
        options = []
        if params[:proxy_address] && params[:proxy_port] && params[:proxy_username] && params[:proxy_password]
          options << "-x #{params[:proxy_address].shellescape}:#{params[:proxy_port].shellescape}"
          options << "--proxy-user #{params[:proxy_username].shellescape}:#{params[:proxy_password].shellescape}"
        end

        options
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload dSYM file to [Splunk MINT](https://mint.splunk.com/)"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :dsym,
                                       env_name: "FL_SPLUNKMINT_FILE",
                                       description: "dSYM.zip file to upload to Splunk MINT",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :api_key,
                                       env_name: "FL_SPLUNKMINT_API_KEY",
                                       description: "Splunk MINT App API key e.g. f57a57ca",
                                       sensitive: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "FL_SPLUNKMINT_API_TOKEN",
                                       description: "Splunk MINT API token e.g. e05ba40754c4869fb7e0b61",
                                       sensitive: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       env_name: "FL_SPLUNKMINT_VERBOSE",
                                       description: "Make detailed output",
                                       is_string: false,
                                       default_value: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :upload_progress,
                                       env_name: "FL_SPLUNKMINT_UPLOAD_PROGRESS",
                                       description: "Show upload progress",
                                       is_string: false,
                                       default_value: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :proxy_username,
                                       env_name: "FL_SPLUNKMINT_PROXY_USERNAME",
                                       description: "Proxy username",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :proxy_password,
                                       env_name: "FL_SPLUNKMINT_PROXY_PASSWORD",
                                       sensitive: true,
                                       description: "Proxy password",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :proxy_address,
                                       env_name: "FL_SPLUNKMINT_PROXY_ADDRESS",
                                       description: "Proxy address",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :proxy_port,
                                       env_name: "FL_SPLUNKMINT_PROXY_PORT",
                                       description: "Proxy port",
                                       optional: true)
        ]
      end

      def self.authors
        ["xfreebird"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.example_code
        [
          'splunkmint(
            dsym: "My.app.dSYM.zip",
            api_key: "43564d3a",
            api_token: "e05456234c4869fb7e0b61"
          )'
        ]
      end

      def self.category
        :beta
      end
    end
  end
end
