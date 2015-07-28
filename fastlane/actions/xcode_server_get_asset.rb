module Fastlane
  module Actions
    module SharedValues
      XCODE_SERVER_GET_ASSET_CUSTOM_VALUE = :XCODE_SERVER_GET_ASSET_CUSTOM_VALUE
    end

    class XcodeServerGetAssetAction < Action

      require 'excon'
      require 'json'

      def self.run(params)

        host = "127.0.0.1"
        username = "user"
        password = "pw"
        trustSelfSigned = true
        bot_name = 'Builda Archiver'

        # setup (not)trusting self signed certificates.
        # it's normal to have a self signed certificate on your Xcode Server
        Excon.defaults[:ssl_verify_peer] = !trustSelfSigned # for self-signed certificates

        # create Xcode Server config
        xcs = XcodeServer.new(host, username, password)
        bots = xcs.fetch_all_bots

        # only keep the ones that perform archive action (create an archive)
        bots.select! { |bot| bot['configuration']['performsArchiveAction'] }

        # pull out names
        bot_names = bots.map { |bot| bot['name'] }

        # match the bot name with a found bot, otherwise fail
        found_bots = bots.select { |bot| bot['name'] == bot_name }
        raise "Failed to find an archiving Bot with name #{bot_name}" if found_bots.count == 0
        bot = found_bots[0]

        # we have our bot, get finished integrations, sorted from newest to oldest
        integrations = xcs.fetch_integrations(bot['_id']).select { |i| i['currentStep'] == 'completed' }
        raise "Failed to find any completed integration for Bot with name #{bot_name}" if found_bots.count == 0

        # pick the first (latest) one for now
        integration = integrations.first

        # fetch assets for this integration
        assets = xcs.fetch_assets(integration['_id'])

        # TODO: somehow make user tell us the bot to use OR make it a parameter to be passed in (the name of the bot)
        # require 'pry'; binding.pry

        # sh "shellcommand ./path"

        # Actions.lane_context[SharedValues::XCODE_SERVER_GET_ASSET_CUSTOM_VALUE] = "my_val"
      end

      class XcodeServer
        def initialize(host, username, password)
          @host = host.start_with?('https://') ? host : "https://#{host}"
          @username = username
          @password = password
        end

        def fetch_all_bots
          response = get_endpoint('/bots')
          raise "Failed to fetch Bots from Xcode Server at #{@host}" if response.status != 200
          bots = JSON.parse(response.body)['results']
        end

        def fetch_integrations(bot_id)
          response = get_endpoint("/bots/#{bot_id}/integrations?limit=10")
          raise "Failed to fetch Integrations for Bot #{bot_id} from Xcode Server at #{@host}" if response.status != 200
          integrations = JSON.parse(response.body)['results']
        end

        def fetch_assets(integration_id)
          url = url_for_endpoint("/integrations/#{integration_id}/assets")


          # TODO: create a temp file, stream the download into it, then pull the real name from headers and move+rename it to the destination place

          
          f = open('./my_file.zip', 'w')
          require 'pry'; binding.pry

          streamer = lambda do |chunk, remaining_bytes, total_bytes|
            # puts chunk
            Helper.log.info "Downloading: #{100 - (100 * remaining_bytes.to_f / total_bytes.to_f).to_i}%".yellow
            f.write(chunk)
          end

          response = Excon.get(url, :response_block => streamer)

          f.close()
          require 'pry'; binding.pry
          
          raise "Failed to fetch Assets for Integration #{integration_id} from Xcode Server at #{@host}" if response.status != 200
          # TODO: try some proper download procedure here, it might be a file of 100s of MBs easily
        end

        def get_endpoint(endpoint)
          url = url_for_endpoint(endpoint)
          require 'base64'
          userpass = "#{@username}:#{@password}"
          headers = { 'Authorization' => "Basic #{Base64.strict_encode64(userpass)}" }
          # TODO: figure out authenticated servers, something's up with Basic Auth :/
          response = Excon.get(url)
          return response
        end

        private 

        def url_for_endpoint(endpoint)
          "#{@host}:20343/api#{endpoint}"
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "A short description with <= 80 characters of what this action does"
      end

      def self.details
        # Optional:
        # this is your change to provide a more detailed description of this action
        "You can use this action to do cool things..."
      end

      def self.available_options
        # Define all options your action supports. 
        
        # Below a few examples
        [
          # FastlaneCore::ConfigItem.new(key: :host,
          #                              env_name: "FL_XCODE_SERVER_GET_ASSET_HOST",
          #                              description: "IP Address/Hostname of Xcode Server",
          #                              optional: false),
          # FastlaneCore::ConfigItem.new(key: :host,
          #                              env_name: "FL_XCODE_SERVER_GET_ASSET_TRUST_SELF_SIGNED_CERTS", # The name of the environment variable
          #                              description: "Trust self signed certificate of Xcode Server", # a short description of this parameter
          #                              optional: true,
          #                              default: true),
          # FastlaneCore::ConfigItem.new(key: :api_token,
          #                              env_name: "FL_XCODE_SERVER_GET_ASSET_API_TOKEN", # The name of the environment variable
          #                              description: "API Token for XcodeServerGetAssetAction", # a short description of this parameter
          #                              verify_block: Proc.new do |value|
          #                                 raise "No API token for XcodeServerGetAssetAction given, pass using `api_token: 'token'`".red unless (value and not value.empty?)
          #                              end),
          # FastlaneCore::ConfigItem.new(key: :development,
          #                              env_name: "FL_XCODE_SERVER_GET_ASSET_DEVELOPMENT",
          #                              description: "Create a development certificate instead of a distribution one",
          #                              is_string: false, # true: verifies the input is a string, false: every kind of value
          #                              default_value: false) # the default value if the user didn't provide one
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['XCODE_SERVER_GET_ASSET_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["Your GitHub/Twitter Name"]
      end

      def self.is_supported?(platform)
        # you can do things like
        # 
        #  true
        # 
        #  platform == :ios
        # 
        #  [:ios, :mac].include?platform
        # 

        platform == :ios
      end
    end
  end
end