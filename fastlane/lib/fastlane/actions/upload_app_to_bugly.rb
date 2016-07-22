module Fastlane
  module Actions
    module SharedValues
      UPLOAD_APP_TO_BUGLY_DOWNLOAD_URL = :UPLOAD_APP_TO_BUGLY_DOWNLOAD_URL
    end

    # To share this integration with the other fastlane users:
    # - Fork https://github.com/fastlane/fastlane/tree/master/fastlane
    # - Clone the forked repository
    # - Move this integration into lib/fastlane/actions
    # - Commit, push and submit the pull request

    class UploadAppToBuglyAction < Action
      def self.run(params)
        require 'json'
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        UI.message "file path: #{params[:file_path]}"
        result_file = File.new('upload_result.json', 'w+')
        result_file.close
        json_file = 'upload_app_to_bugly_result.json'
        secret = ''
        if !params[:secret].to_s.nil? && !params[:secret].empty?
          secret = " -F \"secret=#{params[:secret]}\" "
          UI.message "secret:#{secret}"
        end
        users = ''
        if !params[:users].nil? && !params[:users].empty?
          users = " -F \"users=#{params[:users]}\" "
          UI.message "users:#{users}"
        end
        password = ''
        if !params[:password].nil? && !params[:password].empty?
          password = " -F \"password=#{params[:password]}\" "
          UI.message "password:#{password}"
        end
        download_limit = ''
        if !params[:download_limit].nil? && params[:download_limit] > 0
          download_limit = " -F \"download_limit=#{params[:download_limit]}\" "
          UI.message "download_limit:#{download_limit}"
        end
        cmd = "curl --insecure -F \"file=@#{params[:file_path]}\" -F \"app_id=#{params[:app_id]}\" -F \"pid=#{params[:pid]}\" -F \"title=#{params[:title]}\" -F \"description=#{params[:desc]}\"" + secret + users + password + download_limit + " https://api.bugly.qq.com/beta/apiv1/exp?app_key=#{params[:app_key]} -o " + json_file
        sh(cmd)
        obj = JSON.parse(File.read(json_file))
        ret = obj['rtcode']
        if ret == 0
          url = obj['data']['url']
          Actions.lane_context[SharedValues::UPLOAD_APP_TO_BUGLY_DOWNLOAD_URL] = url
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'A short description with <= 80 characters of what this action does'
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        'You can use this action to do cool things...'
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :file_path,
                                       env_name: 'FL_UPLOAD_APP_TO_BUGLY_FILE_PATH',
                                       description: 'file path for UploadAppToBuglyAction',
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("No file path for UploadAppToBuglyAction given, pass using `file_path: 'path'`") unless value && !value.empty?
                                         UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :app_key,
                                       env_name: 'FL_UPLOAD_APP_TO_BUGLY_APP_KEY',
                                       description: 'app key for UploadAppToBuglyAction',
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("NO app_key for UploadAppToBuglyAction given, pass using `app_key: 'app_key'`") unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :app_id,
                                       env_name: 'FL_UPLOAD_APP_TO_BUGLY_APP_ID',
                                       description: 'app id for UploadAppToBuglyAction',
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("No app_id for UploadAppToBuglyAction given, pass using `app_id: 'app_id'`") unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :pid,
                                       env_name: 'FL_UPLOAD_APP_TO_BUGLY_PID',
                                       description: 'pid for UploadToBuglyAction',
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("No pid for UploadAppToBuglyAction given, pass using `pid: 'pid'`") unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :title,
                                       env_name: 'FL_UPLOAD_APP_TO_BUGLY_TITLE',
                                       description: 'title for UploadAppToBuglyAction',
                                       is_string: true,
                                       default_value: 'title',
                                       verify_block: proc do |value|
                                         UI.user_error!("No title for UploadAppToBuglyAction given, pass using `title: 'title'`") unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :desc,
                                       env_name: 'FL_UPLOAD_APP_TO_BUGLY_DESC',
                                       description: 'desc for UploadAppToBuglyAction',
                                       is_string: true,
                                       default_value: 'desc'),
          FastlaneCore::ConfigItem.new(key: :secret,
                                       env_name: 'FL_UPLOAD_APP_TO_BUGLY_DESCRIPTION',
                                       description: 'secret for UploadAppToBuglyAction',
                                       is_string: true,
                                       default_value: ''),
          FastlaneCore::ConfigItem.new(key: :users,
                                       env_name: 'FL_UPLOAD_APP_TO_BUGLY_DESCRIPTION',
                                       description: 'users for UploadAppToBuglyAction',
                                       is_string: true,
                                       default_value: ''),
          FastlaneCore::ConfigItem.new(key: :password,
                                       env_name: 'FL_UPLOAD_APP_TO_BUGLY_DESCRIPTION',
                                       description: 'password for UploadAppToBuglyAction',
                                       is_string: true,
                                       default_value: ''),
          FastlaneCore::ConfigItem.new(key: :download_limit,
                                       env_name: 'FL_UPLOAD_APP_TO_BUGLY_DESCRIPTION',
                                       description: 'download_limit for UploadAppToBuglyAction',
                                       is_string: false, # true: verifies the input is a string, false: every kind of value
                                       default_value: 10_000)
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        [
          ['UPLOAD_APP_TO_BUGLY_DOWNLOAD_URL', 'download url']
        ]
      end

      def self.return_value
        # If you method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["sexiong306"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
