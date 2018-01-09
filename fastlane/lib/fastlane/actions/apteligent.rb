module Fastlane
  module Actions
    class ApteligentAction < Action
      def self.run(params)
        command = []
        command << "curl"
        command += upload_options(params)
        command << upload_url(params[:app_id].shellescape)

        # Fastlane::Actions.sh has buffering issues, no progress bar is shown in real time
        # will reanable it when it is fixed
        # result = Fastlane::Actions.sh(command.join(' '), log: false)
        shell_command = command.join(' ')
        return shell_command if Helper.is_test?
        result = Actions.sh(shell_command)
        fail_on_error(result)
      end

      def self.fail_on_error(result)
        if result != "200"
          UI.crash!("Server error, failed to upload the dSYM file.")
        else
          UI.success('dSYM successfully uploaded to Apteligent!')
        end
      end

      def self.upload_url(app_id)
        "https://api.crittercism.com/api_beta/dsym/#{app_id}"
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
          UI.user_error!("Couldn't find dSYM file")
        end
      end

      def self.upload_options(params)
        file_path = dsym_path(params).shellescape

        # rubocop: disable Style/FormatStringToken
        options = []
        options << "--write-out %{http_code} --silent --output /dev/null"
        options << "-F dsym=@#{file_path}"
        options << "-F key=#{params[:api_key].shellescape}"
        options
        # rubocop: enable Style/FormatStringToken
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload dSYM file to Apteligent (Crittercism)"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :dsym,
                                       env_name: "FL_APTELIGENT_FILE",
                                       description: "dSYM.zip file to upload to Apteligent",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :app_id,
                                       env_name: "FL_APTELIGENT_APP_ID",
                                      description: "Apteligent App ID key e.g. 569f5c87cb99e10e00c7xxxx",
                                      optional: false),
          FastlaneCore::ConfigItem.new(key: :api_key,
                                       env_name: "FL_APTELIGENT_API_KEY",
                                       sensitive: true,
                                       description: "Apteligent App API key e.g. IXPQIi8yCbHaLliqzRoo065tH0lxxxxx",
                                       optional: false)
        ]
      end

      def self.authors
        ["Mo7amedFouad"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.example_code
        [
          'apteligent(
            app_id: "...",
            api_key: "..."
          )'
        ]
      end

      def self.category
        :beta
      end
    end
  end
end
