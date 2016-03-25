module Fastlane
  module Actions
    class UploadSymbolsToSentryAction < Action
      def self.run(params)
        require 'rest-client'

        # Params - API
        host = params[:api_host]
        api_key = params[:api_key]
        org = params[:org_slug]
        project = params[:project_slug]

        # Params - dSYM
        dsym_path = params[:dsym_path]
        dsym_paths = params[:dsym_paths] || []

        # Url to post dSYMs to
        url = "#{host}/projects/#{org}/#{project}/files/dsyms/"
        resource = RestClient::Resource.new( url, api_key, '' )

        UI.message "Will upload dSYM(s) to #{url}"

        # Upload dsym(s)
        dsym_paths += [dsym_path]
        uploaded_paths = dsym_paths.compact.map do |dsym|
          upload_dsym(resource, dsym)
        end

        # Return uplaoded dSYM paths
        uploaded_paths
      end

      def self.upload_dsym(resource, dsym)
        UI.message "Uploading... #{dsym}"
        resource.post(file: File.new(dsym, 'rb')) unless Helper.test?
        UI.success 'dSYM successfully uploaded to Sentry!'

        dsym
      rescue
        UI.user_error! 'Error while trying to upload dSYM to Sentry'
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload dSYM symbolication files to Sentry"
      end

      def self.details
        [
          "This action allows you to upload symbolication files to Sentry.",
          "It's extra useful if you use it to download the latest dSYM files from Apple when you",
          "use Bitcode"
        ].join(" ")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_host,
                                       env_name: "SENTRY_HOST",
                                       description: "API host url for Sentry",
                                       is_string: true,
                                       default_value: "https://app.getsentry.com/api/0",
                                       optional: true
                                      ),
          FastlaneCore::ConfigItem.new(key: :api_key,
                                       env_name: "SENTRY_API_KEY",
                                       description: "API Key for Sentry",
                                       verify_block: proc do |value|
                                         UI.user_error!("No API token for SentryAction given, pass using `api_key: 'key'`") unless value and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :org_slug,
                                       env_name: "SENTRY_ORG_SLUG",
                                       description: "Organization slug for Sentry project",
                                       verify_block: proc do |value|
                                         UI.user_error!("No organization slug for SentryAction given, pass using `org_slug: 'org'`") unless value and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :project_slug,
                                       env_name: "SENTRY_PROJECT_SLUG",
                                       description: "Prgoject slug for Sentry",
                                       verify_block: proc do |value|
                                         UI.user_error!("No project slug for SentryAction given, pass using `project_slug: 'project'`") unless value and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :dsym_path,
                                       env_name: "SENTRY_DSYM_PATH",
                                       description: "Path to your symbols file. For iOS and Mac provide path to app.dSYM.zip",
                                       default_value: Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH],
                                       optional: true,
                                       verify_block: proc do |value|
                                         # validation is done in the action
                                       end),
          FastlaneCore::ConfigItem.new(key: :dsym_paths,
                                       env_name: "SENTRY_DSYM_PATHS",
                                       description: "Path to an array of your symbols file. For iOS and Mac provide path to app.dSYM.zip",
                                       default_value: Actions.lane_context[SharedValues::DSYM_PATHS],
                                       is_string: false,
                                       optional: true,
                                       verify_block: proc do |value|
                                         # validation is done in the action
                                       end)
        ]
      end

      def self.return_value
        "The uploaded dSYM path(s)"
      end

      def self.authors
        ["joshdholtz"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
