module Fastlane
  module Actions
    module SharedValues
      WIFIDISTRIBUTION_INSTALL_URL = :WIFIDISTRIBUTION_INSTALL_URL
    end

    class DistributorAction < Action
      WIFIDISTRIBUTION_API = "https://wifidistribution.com/api/v1/app"

      def self.run(params)
        UI.success('Upload to DISTRIBUTOR has been started. This may take some time.')

        response = self.upload_build(params)

        case response.status
        when 200...300
          message = response.body
          message.to_json
          UI.success('Build successfully uploaded to DISTRIBUTOR! ' + message['url'])
          Actions.lane_context[SharedValues::WIFIDISTRIBUTION_INSTALL_URL] = message['url']
        else
          UI.user_error!("Error when trying to upload build file to DISTRIBUTOR: #{response.body}")
        end
      end

      def self.upload_build(params)
        require 'faraday'
        require 'faraday_middleware'

        url = WIFIDISTRIBUTION_API
        connection = Faraday.new(url) do |builder|
          builder.request :multipart
          builder.request :url_encoded
          builder.response :json, content_type: /\bjson$/
          builder.use FaradayMiddleware::FollowRedirects
          builder.adapter :net_http
        end

        options = {}
        options[:binary] = Faraday::UploadIO.new(params[:ipa], 'application/octet-stream')

        if params[:app_id]
          options[:id] = params[:app_id]
        end

        post_request = connection.post do |req|
          req.headers["authorization"] = 'Bearer ' + params[:api_token]
          req.body = options
        end

        post_request.on_complete do |env|
          yield env[:status], env[:body] if block_given?
        end
      end

      def self.description
        "Upload a new build to wifidistribution.com"
      end

      def self.details
        "You can use this action to upload or renew your apps on wifidistribution.com"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_token,
                                     env_name: "WIFIDISTRIBUTION_API_TOKEN",
                                     description: "API Token for DISTRIBUTOR",
                                     verify_block: proc do |value|
                                       UI.user_error!("No API token for DISTRIBUTOR given, pass using `api_token: 'token'`") unless value and !value.empty?
                                     end),
          FastlaneCore::ConfigItem.new(key: :ipa,
                                     env_name: "WIFIDISTRIBUTION_IPA_PATH",
                                     description: "Path to your IPA file. Optional if you use the `gym` or `xcodebuild` action",
                                     default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
                                     optional:true),
          FastlaneCore::ConfigItem.new(key: :app_id,
                                     env_name: "WIFIDISTRIBUTION_APP_ID",
                                     description: "ID of your wifidistribution.com app. Optional if want to update an existing app",
                                     is_string: true,
                                     optional: true)
        ]
      end

      def self.output
        [
          ['WIFIDISTRIBUTION_INSTALL_URL', 'The wifidistribution.com install URL for the uploaded ipa']
        ]
      end

      def self.authors
        ["sschlein"]
      end

      def self.is_supported?(platform)
        [:ios].include?(platform)
      end
    end
  end
end
