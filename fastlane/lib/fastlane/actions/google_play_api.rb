module Fastlane
  module Actions
    class GooglePlayApiAction < Action
      def self.run(params)
        require 'supply'
        require 'supply/api_runner'

        result = Supply::ApiRunner.new(
          method: params[:http_method],
          path: params[:path],
          body: params[:body],
          paginate: params[:paginate],
          json_key: params[:json_key],
          json_key_data: params[:json_key_data],
          yes: true
        ).response

        unless result[:status].between?(200, 299)
          handler = params[:error_handlers][result[:status]] || params[:error_handlers]['*']
          UI.user_error!(Supply::ApiRunner.error_message(result)) unless handler
          handler.call(result)
        end
        return result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Send one Google Play Developer API request and return Google's JSON response"
      end

      def self.details
        "Calls any Google Play Developer API endpoint, including those _supply_ has no option for. Uses `json_key` or `json_key_data`, else Application Default Credentials. File uploads (APK, AAB, images) are not supported. The same request is available from the command line as `fastlane supply api`."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :http_method,
                                       description: "The HTTP method: GET, POST, PUT, PATCH or DELETE",
                                       default_value: "GET",
                                       verify_block: proc do |value|
                                         require 'supply/api_runner'
                                         UI.user_error!("Unsupported http_method '#{value}', use one of #{Supply::ApiRunner::METHODS.join(', ')}") unless Supply::ApiRunner::METHODS.include?(value.to_s.upcase)
                                       end),
          FastlaneCore::ConfigItem.new(key: :path,
                                       description: "The request path with its query, e.g. /androidpublisher/v3/applications/com.example/reviews",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :body,
                                       description: "The JSON request body, for POST, PUT and PATCH",
                                       type: Hash,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :paginate,
                                       description: "Follow the next page token and return all pages as one response (GET only)",
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :error_handlers,
                                       description: "Procs called with the result for error statuses, by status code or '*' for any other; without one, an error status fails the lane",
                                       type: Hash,
                                       default_value: {}),
          FastlaneCore::ConfigItem.new(key: :json_key,
                                       env_name: "SUPPLY_JSON_KEY",
                                       conflicting_options: [:json_key_data],
                                       optional: true,
                                       description: "The path to a Google credentials JSON file (Application Default, Workload Identity, or Service Account), used to authenticate with Google",
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:json_key_file),
                                       default_value_dynamic: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Could not find service account json file at path '#{File.expand_path(value)}'") unless File.exist?(File.expand_path(value))
                                       end),
          FastlaneCore::ConfigItem.new(key: :json_key_data,
                                       env_name: "SUPPLY_JSON_KEY_DATA",
                                       conflicting_options: [:json_key],
                                       optional: true,
                                       sensitive: true,
                                       description: "The raw content of a Google credentials JSON file, used to authenticate with Google",
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:json_key_data_raw),
                                       default_value_dynamic: true)
        ]
      end

      def self.return_value
        "A hash with the HTTP status code (:status), the response body as text (:body) and parsed (:json, {} when empty). With paginate, the pages merged into one response"
      end

      def self.return_type
        :hash
      end

      def self.authors
        ["lacostej"]
      end

      def self.is_supported?(platform)
        [:android].include?(platform)
      end

      def self.example_code
        [
          'reviews = google_play_api(path: "/androidpublisher/v3/applications/com.example/reviews", paginate: true, json_key: "play.json") # reviews[:json]["reviews"]',
          'google_play_api(
            path: "/androidpublisher/v3/applications/com.example/edits/123",
            json_key: "play.json",
            error_handlers: { 404 => proc { |result| UI.message("No such edit") } }
          )',
          'edit = google_play_api(http_method: "POST", path: "/androidpublisher/v3/applications/com.example/edits", json_key: "play.json")'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
