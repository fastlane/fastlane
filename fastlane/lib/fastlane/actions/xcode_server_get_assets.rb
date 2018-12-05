module Fastlane
  module Actions
    module SharedValues
      XCODE_SERVER_GET_ASSETS_PATH = :XCODE_SERVER_GET_ASSETS_PATH
      XCODE_SERVER_GET_ASSETS_ARCHIVE_PATH = :XCODE_SERVER_GET_ASSETS_ARCHIVE_PATH
    end

    class XcodeServerGetAssetsAction < Action
      require 'excon'
      require 'json'
      require 'fileutils'

      def self.run(params)
        host = params[:host]
        bot_name = params[:bot_name]
        integration_number_override = params[:integration_number]
        target_folder = params[:target_folder]
        keep_all_assets = params[:keep_all_assets]
        username = params[:username]
        password = params[:password]
        trust_self_signed_certs = params[:trust_self_signed_certs]

        # setup (not)trusting self signed certificates.
        # it's normal to have a self signed certificate on your Xcode Server
        Excon.defaults[:ssl_verify_peer] = !trust_self_signed_certs # for self-signed certificates

        # create Xcode Server config
        xcs = XcodeServer.new(host, username, password)
        bots = xcs.fetch_all_bots

        UI.important("Fetched #{bots.count} Bots from Xcode Server at #{host}.")

        # pull out names
        bot_names = bots.map { |bot| bot['name'] }

        # match the bot name with a found bot, otherwise fail
        found_bots = bots.select { |bot| bot['name'] == bot_name }
        UI.user_error!("Failed to find a Bot with name #{bot_name} on server #{host}, only available Bots: #{bot_names}") if found_bots.count == 0

        bot = found_bots[0]

        UI.success("Found Bot with name #{bot_name} with id #{bot['_id']}.")

        # we have our bot, get finished integrations, sorted from newest to oldest
        integrations = xcs.fetch_integrations(bot['_id']).select { |i| i['currentStep'] == 'completed' }
        UI.user_error!("Failed to find any completed integration for Bot \"#{bot_name}\"") if (integrations || []).count == 0

        # if no integration number is specified, pick the newest one (this is sorted from newest to oldest)
        if integration_number_override
          integration = integrations.find { |i| i['number'] == integration_number_override }
          UI.user_error!("Specified integration number #{integration_number_override} does not exist.") unless integration
        else
          integration = integrations.first
        end

        # consider: only taking the last successful one? or allow failing tests? warnings?

        UI.important("Using integration #{integration['number']}.")

        # fetch assets for this integration
        assets_path = xcs.fetch_assets(integration['_id'], target_folder, self)
        UI.user_error!("Failed to fetch assets for integration #{integration['number']}.") unless assets_path

        asset_entries = Dir.entries(assets_path).map { |i| File.join(assets_path, i) }

        UI.success("Successfully downloaded #{asset_entries.count} assets to file #{assets_path}!")

        # now find the archive and unzip it
        zipped_archive_path = asset_entries.find { |i| i.end_with?('xcarchive.zip') }

        if zipped_archive_path

          UI.important("Found an archive in the assets folder...")

          archive_file_path = File.basename(zipped_archive_path, File.extname(zipped_archive_path))
          archive_dir_path = File.dirname(zipped_archive_path)
          archive_path = File.join(archive_dir_path, archive_file_path)
          if File.exist?(archive_path)
            # we already have the archive, skip
            UI.important("Archive #{archive_path} already exists, not unzipping again...")
          else
            # unzip the archive
            sh("unzip -q \"#{zipped_archive_path}\" -d \"#{archive_dir_path}\"")
          end

          # reload asset entries to also contain the xcarchive file
          asset_entries = Dir.entries(assets_path).map { |i| File.join(assets_path, i) }

          # optionally delete everything except for the archive
          unless keep_all_assets
            files_to_delete = asset_entries.select do |i|
              File.extname(i) != '.xcarchive' && ![".", ".."].include?(File.basename(i))
            end

            files_to_delete.each do |i|
              FileUtils.rm_rf(i)
            end
          end

          Actions.lane_context[SharedValues::XCODE_SERVER_GET_ASSETS_ARCHIVE_PATH] = archive_path
        end

        Actions.lane_context[SharedValues::XCODE_SERVER_GET_ASSETS_PATH] = assets_path

        return assets_path
      end

      class XcodeServer
        def initialize(host, username, password)
          @host = host.start_with?('https://') ? host : "https://#{host}"
          @username = username
          @password = password
        end

        def fetch_all_bots
          response = get_endpoint('/bots')
          UI.user_error!("You are unauthorized to access data on #{@host}, please check that you're passing in a correct username and password.") if response.status == 401
          UI.user_error!("Failed to fetch Bots from Xcode Server at #{@host}, response: #{response.status}: #{response.body}.") if response.status != 200
          JSON.parse(response.body)['results']
        end

        def fetch_integrations(bot_id)
          response = get_endpoint("/bots/#{bot_id}/integrations?last=10")
          UI.user_error!("Failed to fetch Integrations for Bot #{bot_id} from Xcode Server at #{@host}, response: #{response.status}: #{response.body}") if response.status != 200
          JSON.parse(response.body)['results']
        end

        def fetch_assets(integration_id, target_folder, action)
          # create a temp folder and a file, stream the download into it
          Dir.mktmpdir do |dir|
            temp_file = File.join(dir, "tmp_download.#{rand(1_000_000)}")
            f = open(temp_file, 'w')
            streamer = lambda do |chunk, remaining_bytes, total_bytes|
              if remaining_bytes && total_bytes
                UI.important("Downloading: #{100 - (100 * remaining_bytes.to_f / total_bytes.to_f).to_i}%")
              else
                UI.error(chunk.to_s)
              end
              f.write(chunk)
            end

            response = self.get_endpoint("/integrations/#{integration_id}/assets", streamer)
            f.close

            UI.user_error!("Integration doesn't have any assets (it probably never ran).") if response.status == 500
            UI.user_error!("Failed to fetch Assets zip for Integration #{integration_id} from Xcode Server at #{@host}, response: #{response.status}: #{response.body}") if response.status != 200

            # unzip it, it's a .tar.gz file
            out_folder = File.join(dir, "out_#{rand(1_000_000)}")
            FileUtils.mkdir_p(out_folder)

            action.sh("cd \"#{out_folder}\"; cat \"#{temp_file}\" | gzip -d | tar -x")

            # then pull the real name from headers
            asset_filename = response.headers['Content-Disposition'].split(';')[1].split('=')[1].delete('"')
            asset_foldername = asset_filename.split('.')[0]

            # rename the folder in out_folder to asset_foldername
            found_folder = Dir.entries(out_folder).select { |item| item != '.' && item != '..' }[0]

            UI.user_error!("Internal error, couldn't find unzipped folder") if found_folder.nil?

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

        def headers
          require 'base64'
          headers = {
            'User-Agent' => 'fastlane-xcode_server_get_assets', # XCS wants user agent. for some API calls. not for others. sigh.
            'X-XCSAPIVersion' => 1 # XCS API version with this API, Xcode needs this otherwise it explodes in a 500 error fire. Currently Xcode 7 Beta 5 is on Version 5.
          }

          if @username && @password
            userpass = "#{@username}:#{@password}"
            headers['Authorization'] = "Basic #{Base64.strict_encode64(userpass)}"
          end

          return headers
        end

        def get_endpoint(endpoint, response_block = nil)
          url = url_for_endpoint(endpoint)
          headers = self.headers || {}

          if response_block
            response = Excon.get(url, response_block: response_block, headers: headers)
          else
            response = Excon.get(url, headers: headers)
          end

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
        "Downloads Xcode Bot assets like the `.xcarchive` and logs"
      end

      def self.details
        [
          "This action downloads assets from your Xcode Server Bot (works with Xcode Server using Xcode 6 and 7. By default, this action downloads all assets, unzips them and deletes everything except for the `.xcarchive`.",
          "If you'd like to keep all downloaded assets, pass `keep_all_assets: true`.",
          "This action returns the path to the downloaded assets folder and puts into shared values the paths to the asset folder and to the `.xcarchive` inside it."
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :host,
                                       env_name: "FL_XCODE_SERVER_GET_ASSETS_HOST",
                                       description: "IP Address/Hostname of Xcode Server",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :bot_name,
                                       env_name: "FL_XCODE_SERVER_GET_ASSETS_BOT_NAME",
                                       description: "Name of the Bot to pull assets from",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :integration_number,
                                       env_name: "FL_XCODE_SERVER_GET_ASSETS_INTEGRATION_NUMBER",
                                       description: "Optionally you can override which integration's assets should be downloaded. If not provided, the latest integration is used",
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :username,
                                       env_name: "FL_XCODE_SERVER_GET_ASSETS_USERNAME",
                                       description: "Username for your Xcode Server",
                                       optional: true,
                                       default_value: ""),
          FastlaneCore::ConfigItem.new(key: :password,
                                       env_name: "FL_XCODE_SERVER_GET_ASSETS_PASSWORD",
                                       description: "Password for your Xcode Server",
                                       sensitive: true,
                                       optional: true,
                                       default_value: ""),
          FastlaneCore::ConfigItem.new(key: :target_folder,
                                       env_name: "FL_XCODE_SERVER_GET_ASSETS_TARGET_FOLDER",
                                       description: "Relative path to a folder into which to download assets",
                                       optional: true,
                                       default_value: './xcs_assets'),
          FastlaneCore::ConfigItem.new(key: :keep_all_assets,
                                       env_name: "FL_XCODE_SERVER_GET_ASSETS_KEEP_ALL_ASSETS",
                                       description: "Whether to keep all assets or let the script delete everything except for the .xcarchive",
                                       optional: true,
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :trust_self_signed_certs,
                                       env_name: "FL_XCODE_SERVER_GET_ASSETS_TRUST_SELF_SIGNED_CERTS",
                                       description: "Whether to trust self-signed certs on your Xcode Server",
                                       optional: true,
                                       is_string: false,
                                       default_value: true)
        ]
      end

      def self.output
        [
          ['XCODE_SERVER_GET_ASSETS_PATH', 'Absolute path to the downloaded assets folder'],
          ['XCODE_SERVER_GET_ASSETS_ARCHIVE_PATH', 'Absolute path to the downloaded xcarchive file']
        ]
      end

      def self.return_type
        :array_of_strings
      end

      def self.authors
        ["czechboy0"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'xcode_server_get_assets(
            host: "10.99.0.59", # Specify Xcode Server\'s Host or IP Address
            bot_name: "release-1.3.4" # Specify the particular Bot
          )'
        ]
      end

      def self.category
        :testing
      end
    end
  end
end
