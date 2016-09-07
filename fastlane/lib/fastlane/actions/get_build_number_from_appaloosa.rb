module Fastlane
  module Actions

    module SharedValues
      FL_APPALOOSA_BUILD_NUMBER = 0
    end

    class GetBuildNumberFromAppaloosaAction < Action
      def self.run(params)
        require 'net/http'
        require 'json'

        uri = URI("https://www.appaloosa-store.com/api/v2/#{params[:store_id]}/mobile_application_updates?api_key=#{params[:api_token]}&group_name=#{params[:group_name]}")
        app = JSON.parse(Net::HTTP.get(uri))['mobile_application_updates'].detect { |a| a['application_id'] == params[:app_identifier] }

        @current_version = app['version'].to_i rescue 0
        UI.message "The current version for #{params[:app_identifier]} is #{@current_version}"

        @current_version += 1 if params[:with_increment]
        UI.message "This version is incremented to #{@current_version}" if params[:with_increment]

        Actions.lane_context[SharedValues::FL_APPALOOSA_BUILD_NUMBER] = @current_version.to_s
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Retrieve the current build version of a given app. stored into your Appaloosa store."
      end

      def self.details
        "This action allows you to auto increment your app. based on the last build version of your application stored on your Appaloosa store.\n" \
        "When you have several schemes it could be horrible wasting time to upgrade the current build version code manually.\n" \
        "So you could use this action to retrieve (and increment) the last build and upgrade your source with the increment_build_number action."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :app_identifier,
                                       short_option: "-a",
                                       env_name: "FASTLANE_APP_IDENTIFIER",
                                       description: "The bundle identifier of your app",
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)),
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "FL_APPALOOSA_API_TOKEN",
                                       description: "Your API Token",
                                       verify_block: proc do |value|
                                          UI.user_error!("No API token given, pass using `api_token: 'token'`") unless (value and not value.empty?)
                                       end),
           FastlaneCore::ConfigItem.new(key: :store_id,
                                        env_name: "FL_APPALOOSA_STORE_ID",
                                        description: "Your Store id",
                                        verify_block: proc do |value|
                                           UI.user_error!("No store id given, pass using `store_id: 'id'`") unless (value and not value.empty?)
                                        end),
          FastlaneCore::ConfigItem.new(key: :with_increment,
                                       env_name: "FL_APPALOOSA_WITH_INCREMENT",
                                       description: "increment the build_number",
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :group_name,
                                       env_name: "FL_APPALOOSA_GROUP_NAME",
                                       description: "group name containing the selected app",
                                       is_string: true,
                                       default_value: "")
        ]
      end

      def self.output
        [
          ['FL_APPALOOSA_BUILD_NUMBER', 'the build version. (may be incremented)']
        ]
      end

      def self.return_value
        @current_version
      end

      def self.authors
        ["https://github.com/sylvek"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
