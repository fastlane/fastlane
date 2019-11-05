module Fastlane
  module Actions
    module SharedValues
      PODIO_ITEM_URL = :PODIO_ITEM_URL
    end

    class PodioItemAction < Action
      AUTH_URL = 'https://podio.com/oauth/token'
      BASE_URL = 'https://api.podio.com'

      def self.run(params)
        require 'rest_client'
        require 'json'
        require 'uri'

        post_item(params)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Creates or updates an item within your Podio app'
      end

      def self.details
        [
          "Use this action to create or update an item within your Podio app (see [https://help.podio.com/hc/en-us/articles/201019278-Creating-apps-](https://help.podio.com/hc/en-us/articles/201019278-Creating-apps-)).",
          "Pass in dictionary with field keys and their values.",
          "Field key is located under `Modify app` -> `Advanced` -> `Developer` -> `External ID` (see [https://developers.podio.com/examples/items](https://developers.podio.com/examples/items))."
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :client_id,
                                       env_name: 'PODIO_ITEM_CLIENT_ID',
                                       description: 'Client ID for Podio API (see https://developers.podio.com/api-key)',
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("No Client ID for Podio given, pass using `client_id: 'id'`") unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :client_secret,
                                       env_name: 'PODIO_ITEM_CLIENT_SECRET',
                                       sensitive: true,
                                       description: 'Client secret for Podio API (see https://developers.podio.com/api-key)',
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("No Client Secret for Podio given, pass using `client_secret: 'secret'`") unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :app_id,
                                       env_name: 'PODIO_ITEM_APP_ID',
                                       description: 'App ID of the app you intend to authenticate with (see https://developers.podio.com/authentication/app_auth)',
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("No App ID for Podio given, pass using `app_id: 'id'`") unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :app_token,
                                       env_name: 'PODIO_ITEM_APP_TOKEN',
                                       sensitive: true,
                                       description: 'App token of the app you intend to authenticate with (see https://developers.podio.com/authentication/app_auth)',
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("No App token for Podio given, pass using `app_token: 'token'`") unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :identifying_field,
                                       env_name: 'PODIO_ITEM_IDENTIFYING_FIELD',
                                       description: 'String specifying the field key used for identification of an item',
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("No Identifying field given, pass using `identifying_field: 'field name'`") unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :identifying_value,
                                       description: 'String uniquely specifying an item within the app',
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("No Identifying value given, pass using `identifying_value: 'unique value'`") unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :other_fields,
                                       description: 'Dictionary of your app fields. Podio supports several field types, see https://developers.podio.com/doc/items',
                                       is_string: false,
                                       type: Hash,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['PODIO_ITEM_URL', 'URL to newly created (or updated) Podio item']
        ]
      end

      def self.authors
        ['pprochazka72', 'laugejepsen']
      end

      def self.is_supported?(_platform)
        true
      end

      #####################################################
      # @!group Logic
      #####################################################

      def self.post_item(options)
        auth_config = authenticate(options[:client_id],
                                   options[:client_secret],
                                   options[:app_id],
                                   options[:app_token])

        item_id, item_url = get_item(auth_config,
                                     options[:identifying_field],
                                     options[:identifying_value],
                                     options[:app_id])

        unless options[:other_fields].nil?
          options[:other_fields].each do |key, value|
            uri = URI.parse(value)
            if uri.kind_of?(URI::HTTP)
              link_embed_id = get_embed_id(auth_config, uri)
              options[:other_fields].merge!(key => link_embed_id)
            end
          end
          update_item(auth_config, item_id, options[:other_fields])
        end

        Actions.lane_context[SharedValues::PODIO_ITEM_URL] = item_url
      end

      def self.authenticate(client_id, client_secret, app_id, app_token)
        auth_response = RestClient.post(AUTH_URL, grant_type: 'app',
                                                  app_id: app_id,
                                                  app_token: app_token,
                                                  client_id: client_id,
                                                  client_secret: client_secret)
        UI.user_error!("Failed to authenticate with Podio API") if auth_response.code != 200

        auth_response_dictionary = JSON.parse(auth_response.body)
        access_token = auth_response_dictionary['access_token']

        { Authorization: "OAuth2 #{access_token}", content_type: :json, accept: :json }
      end

      def self.get_item(auth_config, identifying_field, identifying_value, app_id)
        item_id, item_url = get_existing_item(auth_config, identifying_value, app_id)

        unless item_id
          item_id, item_url = create_item(auth_config, identifying_field, identifying_value, app_id)
        end

        [item_id, item_url]
      end

      def self.get_existing_item(auth_config, identifying_value, app_id)
        filter_request_body = { query: identifying_value, limit: 1, ref_type: 'item' }.to_json
        filter_response = RestClient.post("#{BASE_URL}/search/app/#{app_id}/", filter_request_body, auth_config)
        UI.user_error!("Failed to search for already existing item #{identifying_value}") if filter_response.code != 200

        existing_items = JSON.parse(filter_response.body)
        existing_item_id = nil
        existing_item_url = nil
        if existing_items.length > 0
          existing_item = existing_items[0]
          if existing_item['title'] == identifying_value
            existing_item_id = existing_item['id']
            existing_item_url = existing_item['link']
          end
        end

        [existing_item_id, existing_item_url]
      end

      def self.create_item(auth_config, identifying_field, identifying_value, app_id)
        item_request_body = { fields: { identifying_field => identifying_value } }.to_json
        item_response = RestClient.post("#{BASE_URL}/item/app/#{app_id}", item_request_body, auth_config)
        UI.user_error!("Failed to create item \"#{identifying_value}\"") if item_response.code != 200

        item_response_dictionary = JSON.parse(item_response.body)
        [item_response_dictionary['item_id'], item_response_dictionary['link']]
      end

      def self.update_item(auth_config, item_id, fields)
        if fields.length > 0
          item_request_body = { fields: fields }.to_json
          item_response = RestClient.put("#{BASE_URL}/item/#{item_id}", item_request_body, auth_config)
          UI.user_error!("Failed to update item values \"#{fields}\"") unless item_response.code != 200 || item_response.code != 204
        end
      end

      def self.get_embed_id(auth_config, url)
        embed_request_body = { url: url }.to_json
        embed_response = RestClient.post("#{BASE_URL}/embed/", embed_request_body, auth_config)
        UI.user_error!("Failed to create embed for link #{link}") if embed_response.code != 200

        embed_response_dictionary = JSON.parse(embed_response.body)
        embed_response_dictionary['embed_id']
      end

      def self.example_code
        [
          'podio_item(
            identifying_value: "Your unique value",
            other_fields: {
              "field1" => "fieldValue",
              "field2" => "fieldValue2"
            }
          )'
        ]
      end

      def self.category
        :beta
      end
    end
  end
end
