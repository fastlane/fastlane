module Fastlane
  module Actions
    class AppcenterAction < Action
      def self.run(params)
        puts("This is fine!")

        require 'net/http'
        require 'net/http/post/multipart'
        require 'uri'
        require 'json'
        require 'rest-client'
        require 'pry'

        # Create a release upload
        response = create_release_uploads(params)
        json = parse_response(response) # this will raise an exception if something goes wrong

        if json['upload_url'] && json['upload_id']
          upload_url = json['upload_url']
          upload_id = json['upload_id']

          ipa_filename = params[:ipa]
          upload_build(upload_url, ipa_filename)
          response = finalize_upload(upload_id, params)
          json = parse_response(response)
          unless json['release_id'].nil?
            response = distribute_release(params, json['release_id'], params[:destination_name], params[:release_notes])
            if response.code == '200'
              puts('all good 🙌')
              puts(response.body)
              puts(json['release_id'])
            else
              puts('all not good 💣')
            end
          end
        end
      end

      def self.appcenter_url(options)
        "https://api.appcenter.ms/v0.1/apps/#{options[:owner]}/#{options[:app_name]}"
      end
      private_class_method :appcenter_url

      def self.create_release_uploads(params)
        uri = URI.parse(appcenter_url(params) + '/release_uploads')
        req = Net::HTTP::Post.new(uri.request_uri, { 'Content-Type' => 'application/json' })

        req['X-API-Token'] = params[:api_token]

        # req.body = JSON.generate(body)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        response = http.request(req)
        response
      end
      private_class_method :create_release_uploads

      def self.upload_build(upload_url, file_path)
        params = { ipa: File.new(file_path, 'rb') }
        response = RestClient.post(upload_url, params)
        if response.code != 204
          UI.error("error while uploading")
        end
      end
      private_class_method :upload_build

      def self.finalize_upload(upload_id, params)
        uri = URI.parse('https://api.appcenter.ms/v0.1/apps/rtayal11-k5gi/Shopify-Test/release_uploads/a0967e20-3c13-0136-17ea-12b638cfd350') # appcenter_url(params) + "/release_uploads/#{upload_id}")

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        req = Net::HTTP::Patch.new(uri)
        req['X-API-Token'] = params[:api_token]
        req["Content-Type"] = 'application/json'
        req["Accept"] = 'application/json'
        req.body = JSON.generate({ status: "committed" })

        response = http.request(req)
        response
      end
      private_class_method :finalize_upload

      def self.distribute_release(params, release_id, destination_name, release_notes)
        uri = URI.parse(appcenter_url(params) + "/releases/#{release_id}")

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        req = Net::HTTP::Patch.new(uri)
        req['X-API-Token'] = params[:api_token]
        req["Content-Type"] = 'application/json'
        req["Accept"] = 'application/json'
        req.body = JSON.generate({ destination_name: destination_name, release_notes: release_notes })

        response = http.request(req)
        response
      end
      private_class_method :distribute_release

      def self.parse_response(response)
        body = JSON.parse(response.body)
        return body
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
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "APPCENTER_API_TOKEN",
                                       description: "Appcenter API token",
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :owner,
                                       env_name: "APPCENTER_OWNER",
                                       description: "Appcenter owner",
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :app_name,
                                       env_name: "APPCENTER_APP_NAME",
                                       description: "Appcenter app name",
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :destination_name,
                                       env_name: "APPCENTER_DESTINATION_NAME",
                                       description: "Appcenter distribution group",
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :release_notes,
                                       env_name: "APPCENTER_RELEASE_NOTES",
                                       description: "Release notes",
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :apk,
                                       env_name: "APPCENTER_APK",
                                       description: "Path to your APK file",
                                       default_value: Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH],
                                       default_value_dynamic: true,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find apk file at path '#{value}'") unless File.exist?(value)
                                       end,
                                       conflicting_options: [:ipa],
                                       conflict_block: proc do |value|
                                         UI.user_error!("You can't use 'apk' and '#{value.key}' options in one run")
                                       end),
          FastlaneCore::ConfigItem.new(key: :ipa,
                                       env_name: "APPCENTER_IPA",
                                       description: "Path to your IPA file. Optional if you use the _gym_ or _xcodebuild_ action. For Android provide path to .apk file",
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
                                       default_value_dynamic: true,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find ipa file at path '#{value}'") unless File.exist?(value)
                                       end,
                                       conflicting_options: [:apk],
                                       conflict_block: proc do |value|
                                         UI.user_error!("You can't use 'ipa' and '#{value.key}' options in one run")
                                       end)
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
