module Fastlane
  module Actions
    module SharedValues
      BUGTAGS_CUSTOM_VALUE = :BUGTAGS_CUSTOM_VALUE
    end

    class BugtagsAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        # UI.message "Parameter API Token: #{params[:api_token]}"
        command = []
        command << "curl"
        command << "\"https://work.bugtags.com/api/apps/symbols/upload\""
        command << "--write-out %{http_code} --silent"
        command += handle_params(params)
        command += handle_plistinfo(params)

        # sh "shellcommand ./path"
        shell_command = command.join(' ')
        result = Actions.sh(shell_command)
        return result
        # Actions.lane_context[SharedValues::BUGTAGS_CUSTOM_VALUE] = "my_val"
      end

      def self.handle_params(params)
        result = []
        result << "-F \"file=@#{params[:dsym].shellescape};type=application/octet-stream\""
        result << "-F \"app_key=#{params[:app_key].shellescape}\""
        result << "-F \"secret_key=#{params[:secret_key].shellescape}\""
        return result
      end

      def self.handle_plistinfo(params)
        result = []
        result << "-F \"version_name=#{params[:app_version].shellescape}\""
        result << "-F \"version_code=#{params[:app_build].shellescape}\""
        return result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload dSYM file to [Bugtags](https://work.bugtags.com/)"
      end

      def self.details
        "Upload dSYM file to [Bugtags], to tracing crashes"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :dsym,
                                     env_name: "FL_BUGTAGS_DSYM_FILE",
                                     description: "the dSYM.zip file to upload to Bugtags",
                                     verify_block: proc do |value|
                                        UI.user_error!("No dsym for BugtagsAction given, pass using `dsym: 'dsym file's path'`") unless (value and not value.empty?)
                                     end),
          FastlaneCore::ConfigItem.new(key: :app_version,
                                   env_name: "FL_BUGTAGS_APP_VERSION",
                                   description: "the version in your project's info.plist",
                                   verify_block: proc do |value|
                                    UI.user_error!("No version for BugtagsAction given, pass using `dsym: 'app_version file's path'`") unless (value and not value.empty?)
                                   end),
          FastlaneCore::ConfigItem.new(key: :app_build,
                                   env_name: "FL_BUGTAGS_APP_BUILD",
                                   description: "the build version in your project's info.plist",
                                   verify_block: proc do |value|
                                      UI.user_error!("No build version for BugtagsAction given, pass using `app_build: 'build version'`") unless (value and not value.empty?)
                                   end),
          FastlaneCore::ConfigItem.new(key: :app_key,
                                   env_name: "FL_BUGTAGS_APP_KEY",
                                   description: "Bugtags App ID key e.g. 29f35c87cb99e10e00c7xxxx",
                                   verify_block: proc do |value|
                                      UI.user_error!("No App ID for BugtagsAction given, pass using `app_key: 'Bugtags App ID key'`") unless (value and not value.empty?)
                                   end),
          FastlaneCore::ConfigItem.new(key: :secret_key,
                                   env_name: "FL_BUGTAGS_SECRET_KEY",
                                   description: "Bugtags App Secret key e.g. 29f35c87cb99e10e00c7xxxx",
                                   verify_block: proc do |value|
                                      UI.user_error!("No App Secret for BugtagsAction given, pass using `secret_key: 'Bugtags App Secret key'`") unless (value and not value.empty?)
                                   end)
        ]
      end


      def self.authors
        ["wliu6"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.example_code
        [
          'bugtags(
            dsym: "...",
            app_key: "...",
            secret_key: "...",
            app_version: "...",
            app_build: "...",
          )'
        ]
      end

      def self.category
        :beta
      end
    end
  end
end
