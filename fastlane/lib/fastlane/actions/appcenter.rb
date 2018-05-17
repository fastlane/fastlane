module Fastlane
  module Actions
    class AppcenterAction < Action
      def self.run(params)
        puts "This is fine!"

        require 'net/http'
        require 'net/http/post/multipart'
        require 'uri'
        require 'json'

        uri = URI.parse(appcenter_url(params))
        req = create_request(uri)
        req.basic_auth(params[:api_token], nil)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        response = http.request(req)

        parse_response(response) # this will raise an exception if something goes wrong

      end

      def self.appcenter_url(options)
        "https://api.appcenter.ms/v0.1/apps/#{options[:owner]}/#{options[:app_name]}"
      end
      private_class_method :appcenter_url

      def self.create_request(uri)
        puts "uri: #{uri.request_uri}"
        req = Net::HTTP::Post.new(uri.request_uri, { 'Content-Type' => 'application/json' })
          # req.body = JSON.generate(params)
        
        req
      end
      private_class_method :create_request

      def self.parse_response(response)
        body = JSON.parse(response.body)
        puts body
        # app_url = body['appURL']
        # manage_url = body['manageURL']
        # public_key = body['publicKey']

        # Actions.lane_context[SharedValues::APPETIZE_PUBLIC_KEY] = public_key
        # Actions.lane_context[SharedValues::APPETIZE_APP_URL] = app_url
        # Actions.lane_context[SharedValues::APPETIZE_MANAGE_URL] = manage_url
        return true
      rescue => ex
        UI.error(ex)
        UI.user_error!("Error uploading to Appcenter.ms: #{response.body}")
      end
      private_class_method :parse_response

      def self.description
        "Upload a new build to Appcenter"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :owner,
                                       env_name: "APPCENTER_OWNER",
                                       description: "Appcenter owner",
                                       is_string: true
                                       ),
          FastlaneCore::ConfigItem.new(key: :app_name,
                                       env_name: "APPCENTER_APP_NAME",
                                       description: "Appcenter app name",
                                       is_string: true
                                       )
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac, :android].include?(platform)
      end

      def self.author
        ["RishabhTayal"]
      end

      def self.details
        [
          "Additionally, you can specify `notes`, `emails`, `groups` and `notifications`.",
          "Distributing to Groups: When using the `groups` parameter, it's important to use the group **alias** names for each group you'd like to distribute to. A group's alias can be found in the web UI. If you're viewing the Beta page, you can open the groups dialog by clicking the 'Manage Groups' button."
        ].join("\n")
      end

      def self.example_code
        [
          'appcenter'
        ]
      end

      def self.category
        :beta
      end
    end
  end
end
