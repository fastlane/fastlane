module Fastlane
  module Actions
    class ApteligentAction < Action
      def self.run(params)
        command = []
        command << "curl"
        command += upload_options(params)
        command << upload_url(params[:app_id])

        # Fastlane::Actions.sh has buffering issues, no progress bar is shown in real time
        # will reanable it when it is fixed
        # result = Fastlane::Actions.sh(command.join(' '), log: false)
        shell_command = command.join(' ')
        result = Helper.is_test? ? shell_command : `#{shell_command}`
        fail_on_error(result)
        result
      end

      def self.fail_on_error(result)
        if result.include?("error")
          raise "Server error, failed to upload the dSYM file".red
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
          raise "Couldn't find file at path '#{expanded_file_path}'".red unless File.exist?(expanded_file_path)

          return expanded_file_path
        else
          raise "Couldn't find any dSYM file".red
        end
      end

      def self.upload_options(params)
        file_path = dsym_path(params).shellescape

        options = []
        options << "--silent"
        options << "-F dsym=@#{file_path}"
        options << "-F dsym=@#{file_path}"
        options
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
          FastlaneCore::ConfigItem.new(key: :api_key,
                                       env_name: "FL_APTELIGENT_API_KEY",
                                       description: "Apteligent App API key e.g. IXPQIi8yCbHaLliqzRoo065tH0lxxxxx",
                                       optional: false),

          FastlaneCore::ConfigItem.new(key: :app_id,
                             env_name: "FL_APTELIGENT_APP_ID",
                             description: "Apteligent App ID key e.g. 569f5c87cb99e10e00c7xxxx",
                             optional: false)

        ]
      end

      def self.authors
        ["Mo7amedFouad"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end