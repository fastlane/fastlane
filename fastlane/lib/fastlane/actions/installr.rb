module Fastlane
  module Actions
    module SharedValues
      INSTALLR_BUILD_INFORMATION = :INSTALLR_BUILD_INFORMATION
    end

    class InstallrAction < Action
      INSTALLR_API = "https://www.installrapp.com/apps.json"

      def self.run(params)
        UI.success('Upload to Installr has been started. This may take some time.')

        response = self.upload_build(params)

        case response.status
        when 200...300
          Actions.lane_context[SharedValues::INSTALLR_BUILD_INFORMATION] = response.body
          UI.success('Build successfully uploaded to Installr!')
        else
          UI.user_error!("Error when trying to upload build file to Installr: #{response.body}")
        end
      end

      def self.upload_build(params)
        require 'faraday'
        require 'faraday_middleware'

        url = INSTALLR_API
        connection = Faraday.new(url) do |builder|
          builder.request(:multipart)
          builder.request(:url_encoded)
          builder.response(:json, content_type: /\bjson$/)
          builder.use(FaradayMiddleware::FollowRedirects)
          builder.adapter(:net_http)
        end

        options = {}
        options[:qqfile] = Faraday::UploadIO.new(params[:ipa], 'application/octet-stream')

        if params[:notes]
          options[:releaseNotes] = params[:notes]
        end

        if params[:notify]
          options[:notify] = params[:notify]
        end

        if params[:add]
          options[:add] = params[:add]
        end

        post_request = connection.post do |req|
          req.headers['X-InstallrAppToken'] = params[:api_token]
          req.body = options
        end

        post_request.on_complete do |env|
          yield(env[:status], env[:body]) if block_given?
        end
      end

      def self.description
        "Upload a new build to [Installr](http://installrapp.com/)"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "INSTALLR_API_TOKEN",
                                       sensitive: true,
                                       description: "API Token for Installr Access",
                                       verify_block: proc do |value|
                                         UI.user_error!("No API token for Installr given, pass using `api_token: 'token'`") unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :ipa,
                                       env_name: "INSTALLR_IPA_PATH",
                                       description: "Path to your IPA file. Optional if you use the _gym_ or _xcodebuild_ action",
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
                                       default_value_dynamic: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find build file at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :notes,
                                       env_name: "INSTALLR_NOTES",
                                       description: "Release notes",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :notify,
                                       env_name: "INSTALLR_NOTIFY",
                                       description: "Groups to notify (e.g. 'dev,qa')",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :add,
                                       env_name: "INSTALLR_ADD",
                                       description: "Groups to add (e.g. 'exec,ops')",
                                       optional: true)
        ]
      end

      def self.output
        [
          ['INSTALLR_BUILD_INFORMATION', 'Contains release info like :appData. See http://help.installrapp.com/api/']
        ]
      end

      def self.authors
        ["scottrhoyt"]
      end

      def self.is_supported?(platform)
        [:ios].include?(platform)
      end

      def self.example_code
        [
          'installr(
            api_token: "...",
            ipa: "test.ipa",
            notes: "The next great version of the app!",
            notify: "dev,qa",
            add: "exec,ops"
          )'
        ]
      end

      def self.category
        :beta
      end
    end
  end
end
