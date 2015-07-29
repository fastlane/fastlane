module Fastlane
  module Actions
    module SharedValues
      XCODE_SERVER_GET_ASSET_ARCHIVE_PATH = :XCODE_SERVER_GET_ASSET_ARCHIVE_PATH
    end

    class XcodeServerGetAssetAction < Action

      require 'excon'
      require 'json'
      require 'fileutils'

      def self.run(params)

        host = "10.99.0.57"
        username = "user"
        password = "pw"
        trustSelfSigned = true

        # TODO: somehow make user tell us the bot to use OR make it a parameter to be passed in (the name of the bot)
        bot_name = 'neverland-release'
        target_folder = './xcs_assets'

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
        # TODO: only take the last successful one? or allow failing tests? warnings?
        integration = integrations.first

        # fetch assets for this integration
        assets_file_path = xcs.fetch_assets(integration['_id'], target_folder, self)
        asset_entries = Dir.entries(assets_file_path).map { |i| File.join(assets_file_path, i) }

        Helper.log.info "Successfully downloaded #{asset_entries.count} assets to file #{assets_file_path}!".green

        # now find the archive, unzip it and return a path to it from the action
        zipped_archive_path = asset_entries.select { |i| i.end_with?('xcarchive.zip') }.first

        raise "Could not find xcarchive" if zipped_archive_path == nil

        archive_file_path = File.basename(zipped_archive_path, File.extname(zipped_archive_path))
        archive_dir_path = File.dirname(zipped_archive_path)
        archive_path = File.join(archive_dir_path, archive_file_path)
        sh "unzip -q \"#{zipped_archive_path}\" -d \"#{archive_dir_path}\""

        # delete everything except for the archive
        # TODO: make deleting of the other assets an option, default to true
        files_to_delete = asset_entries.select do |i| 
          File.extname(i) != 'xcarchive' && ![".", ".."].include?(File.basename(i))
        end

        files_to_delete.each do |i|
          FileUtils.rm_rf(i)
        end

        Actions.lane_context[SharedValues::XCODE_SERVER_GET_ASSET_ARCHIVE_PATH] = archive_path
        return archive_path
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

        def fetch_assets(integration_id, target_folder, action)
          url = url_for_endpoint("/integrations/#{integration_id}/assets")

          # create a temp folder and a file, stream the download into it
          Dir.mktmpdir do |dir|

            temp_file = File.join(dir, "tmp_download.#{rand(1000000)}")
            f = open(temp_file, 'w')
            streamer = lambda do |chunk, remaining_bytes, total_bytes|
              # puts chunk
              Helper.log.info "Downloading: #{100 - (100 * remaining_bytes.to_f / total_bytes.to_f).to_i}%".yellow
              f.write(chunk)
            end

            response = Excon.get(url, :response_block => streamer)
            f.close()

            raise "Failed to fetch Assets zip for Integration #{integration_id} from Xcode Server at #{@host}" if response.status != 200

            # unzip it, it's a .tar.gz file
            out_folder = File.join(dir, "out_#{rand(1000000)}")
            FileUtils.mkdir_p(out_folder)

            action.sh "cd \"#{out_folder}\"; cat \"#{temp_file}\" | gzip -d | tar -x"

            # then pull the real name from headers
            asset_filename = response.headers['Content-Disposition'].split(';')[1].split('=')[1].gsub('"', '')
            asset_foldername = asset_filename.split('.')[0]

            # rename the folder in out_folder to asset_foldername
            found_folder = Dir.entries(out_folder).select { |item| item != '.' && item != '..' }[0]

            raise "Internal error, couldn't find unzipped folder" if found_folder == nil

            unzipped_folder_temp_name = File.join(out_folder, found_folder)
            unzipped_folder = File.join(out_folder, asset_foldername)

            # rename to destination name
            FileUtils.mv(unzipped_folder_temp_name, unzipped_folder)

            target_folder = File.absolute_path(target_folder)

            # create target folder if it doesn't exist
            FileUtils.mkdir_p(target_folder)

            # and move+rename it to the destination place
            FileUtils.cp_r(unzipped_folder, target_folder)
            out = File.join(target_folder, asset_foldername)

            return out
          end
          return nil
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
        [
          ['XCODE_SERVER_GET_ASSET_ARCHIVE_PATH', 'Absolute path to the downloaded xcarchive file']
        ]
      end

      def self.authors
        ["czechboy0"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end