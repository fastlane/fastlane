module Fastlane
  module Actions
    module SharedValues
      DSYM_PATHS = :DSYM_PATHS
      DSYM_LATEST_UPLOADED_DATE = :DSYM_LATEST_UPLOADED_DATE
    end
    class DownloadDsymsAction < Action
      # rubocop:disable Metrics/PerceivedComplexity
      def self.run(params)
        require 'openssl'
        require 'spaceship'
        require 'net/http'
        require 'date'

        if !params[:api_token].nil?
          UI.message('Passing given authorization token for App Store Connect API')
          api_token = Spaceship::ConnectAPI::Token.from_token(params[:api_token])
          Spaceship::ConnectAPI.token = api_token
        elsif (api_token = Spaceship::ConnectAPI::Token.from(hash: params[:api_key], filepath: params[:api_key_path]))
          UI.message("Creating authorization token for App Store Connect API")
          Spaceship::ConnectAPI.token = api_token
        elsif !Spaceship::ConnectAPI.token.nil?
          UI.message("Using existing authorization token for App Store Connect API")
        else
          # Team selection passed though FASTLANE_ITC_TEAM_ID and FASTLANE_ITC_TEAM_NAME environment variables
          # Prompts select team if multiple teams and none specified
          UI.message("Login to App Store Connect (#{params[:username]})")
          Spaceship::ConnectAPI.login(params[:username], use_portal: false, use_tunes: true)
          UI.message("Login successful")
        end

        # Get App
        app = Spaceship::ConnectAPI::App.find(params[:app_identifier])
        unless app
          UI.user_error!("Could not find app with bundle identifier '#{params[:app_identifier]}' on account #{params[:username]}")
        end

        # Process options
        version = params[:version]
        build_number = params[:build_number].to_s unless params[:build_number].nil?
        itc_platform = params[:platform]
        output_directory = params[:output_directory]
        wait_for_dsym_processing = params[:wait_for_dsym_processing]
        wait_timeout = params[:wait_timeout]
        min_version = Gem::Version.new(params[:min_version]) if params[:min_version]
        after_uploaded_date = DateTime.parse(params[:after_uploaded_date]) unless params[:after_uploaded_date].nil?

        platform = Spaceship::ConnectAPI::Platform.map(itc_platform)

        # Set version if it is latest
        if version == 'latest'
          # Try to grab the edit version first, else fallback to live version
          UI.message("Looking for latest build...")
          latest_build = get_latest_build!(app_id: app.id, platform: platform)
          version = latest_build.app_version
          build_number = latest_build.version
        elsif version == 'live'
          UI.message("Looking for live version...")
          live_version = app.get_live_app_store_version(platform: platform)

          UI.user_error!("Could not find live version for your app, please try setting 'latest' or a specific version") if live_version.nil?

          # No need to search for candidates, because released App Store version should only have one build
          version = live_version.version_string
          build_number = live_version.build.version
        end

        # Make sure output_directory has a slash on the end
        if output_directory && !output_directory.end_with?('/')
          output_directory += '/'
        end

        # Write a nice message
        message = []
        message << "Looking for dSYM files for '#{params[:app_identifier]}' on platform #{platform}"
        message << "v#{version}" if version
        message << "(#{build_number})" if build_number
        UI.message(message.join(" "))

        filter = { app: app.id }
        filter["preReleaseVersion.platform"] = platform
        filter["preReleaseVersion.version"] = version if version
        filter["version"] = build_number if build_number
        build_resp = Spaceship::ConnectAPI.get_builds(filter: filter, sort: "-uploadedDate", includes: "preReleaseVersion,buildBundles")

        build_resp.all_pages_each do |build|
          asc_app_version = build.app_version
          asc_build_number = build.version
          uploaded_date = DateTime.parse(build.uploaded_date)

          message = []
          message << "Found train (version): #{asc_app_version}"
          message << ", comparing to supplied version: #{version}" if version
          UI.verbose(message.join(" "))

          if version && version != asc_app_version
            UI.verbose("Version #{version} doesn't match: #{asc_app_version}")
            next
          end

          if min_version && min_version > Gem::Version.new(asc_app_version)
            UI.verbose("Min version #{min_version} not reached: #{asc_app_version}")
            next
          end

          if after_uploaded_date && after_uploaded_date >= uploaded_date
            UI.verbose("Upload date #{after_uploaded_date} not reached: #{uploaded_date}")
            break
          end

          message = []
          message << "Found build version: #{asc_build_number}"
          message << ", comparing to supplied build_number: #{build_number}" if build_number
          UI.verbose(message.join(" "))

          if build_number && asc_build_number != build_number
            UI.verbose("build_version: #{asc_build_number} doesn't match: #{build_number}")
            next
          end

          UI.verbose("Build_version: #{asc_build_number} matches #{build_number}, grabbing dsym_url") if build_number
          download_dsym(build: build, app: app, wait_for_dsym_processing: wait_for_dsym_processing, wait_timeout: wait_timeout, output_directory: output_directory)
        end
      end

      def self.download_dsym(build: nil, app: nil, wait_for_dsym_processing: nil, wait_timeout: nil, output_directory: nil)
        start = Time.now
        dsym_urls = []

        loop do
          build_bundles = build.build_bundles.select { |b| b.includes_symbols == true }
          dsym_urls = build_bundles.map(&:dsym_url).compact

          break if build_bundles.count == dsym_urls.count

          if !wait_for_dsym_processing || (Time.now - start) > wait_timeout
            # In some cases, AppStoreConnect does not process the dSYMs, thus no error should be thrown.
            UI.message("Could not find any dSYM for #{build.version} (#{build.app_version})")
            break
          else
            UI.message("Waiting for dSYM file to appear...")
            sleep(30) unless FastlaneCore::Helper.is_test?
            build = Spaceship::ConnectAPI::Build.get(build_id: build.id)
          end
        end

        if dsym_urls.count == 0
          UI.message("No dSYM URL for #{build.version} (#{build.app_version})")
        else
          dsym_urls.each do |url|
            self.download(url, build, app, output_directory)
          end
        end
      end

      # rubocop:enable Metrics/PerceivedComplexity

      def self.get_latest_build!(app_id: nil, platform: nil)
        filter = { app: app_id }
        filter["preReleaseVersion.platform"] = platform
        latest_build = Spaceship::ConnectAPI.get_builds(filter: filter, sort: "-uploadedDate", includes: "preReleaseVersion,buildBundles").first

        if latest_build.nil?
          UI.user_error!("Could not find any build for platform #{platform}") if platform
          UI.user_error!("Could not find any build")
        end

        return latest_build
      end

      def self.download(download_url, build, app, output_directory)
        result = self.download_file(download_url)
        path   = write_dsym(result, app.bundle_id, build.app_version, build.version, output_directory)
        UI.success("🔑  Successfully downloaded dSYM file for #{build.app_version} - #{build.version} to '#{path}'")

        Actions.lane_context[SharedValues::DSYM_PATHS] ||= []
        Actions.lane_context[SharedValues::DSYM_PATHS] << File.expand_path(path)

        unless build.uploaded_date.nil?
          Actions.lane_context[SharedValues::DSYM_LATEST_UPLOADED_DATE] ||= build.uploaded_date
          current_latest = Actions.lane_context[SharedValues::DSYM_LATEST_UPLOADED_DATE]
          Actions.lane_context[SharedValues::DSYM_LATEST_UPLOADED_DATE] = [current_latest, build.uploaded_date].max
          UI.verbose("Most recent build uploaded_date #{Actions.lane_context[SharedValues::DSYM_LATEST_UPLOADED_DATE]}")
        end
      end

      def self.write_dsym(data, bundle_id, train_number, build_number, output_directory)
        file_name = "#{bundle_id}-#{train_number}-#{build_number}.dSYM.zip"
        if output_directory
          file_name = output_directory + file_name
        end
        File.binwrite(file_name, data)
        file_name
      end

      def self.download_file(url)
        uri = URI.parse(url)
        if ENV['http_proxy']
          UI.verbose("Found 'http_proxy' environment variable so connect via proxy")
          proxy_uri = URI.parse(ENV['http_proxy'])
          http = Net::HTTP.new(uri.host, uri.port, proxy_uri.host, proxy_uri.port)
        else
          http = Net::HTTP.new(uri.host, uri.port)
        end
        http.read_timeout = 300
        http.use_ssl = (uri.scheme == "https")
        res = http.get(uri.request_uri)
        res.body
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Download dSYM files from App Store Connect for Bitcode apps"
      end

      def self.details
        sample = <<-SAMPLE.markdown_sample
          ```ruby
          lane :refresh_dsyms do
            download_dsyms                  # Download dSYM files from iTC
            upload_symbols_to_crashlytics   # Upload them to Crashlytics
            clean_build_artifacts           # Delete the local dSYM files
          end
          ```
        SAMPLE

        [
          "This action downloads dSYM files from App Store Connect after the ipa gets re-compiled by Apple. Useful if you have Bitcode enabled.".markdown_preserve_newlines,
          sample
        ].join("\n")
      end

      def self.available_options
        user = CredentialsManager::AppfileConfig.try_fetch_value(:itunes_connect_id)
        user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

        [
          FastlaneCore::ConfigItem.new(key: :api_key_path,
                                       env_names: ["DOWNLOAD_DSYMS_API_KEY_PATH", "APP_STORE_CONNECT_API_KEY_PATH"],
                                       description: "Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)",
                                       optional: true,
                                       conflicting_options: [:api_key, :api_token],
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find API key JSON file at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :api_key,
                                       env_names: ["DOWNLOAD_DSYMS_API_KEY", "APP_STORE_CONNECT_API_KEY"],
                                       description: "Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#use-return-value-and-pass-in-as-an-option)",
                                       type: Hash,
                                       default_value: Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::APP_STORE_CONNECT_API_KEY],
                                       default_value_dynamic: true,
                                       optional: true,
                                       sensitive: true,
                                       conflicting_options: [:api_key_path, :api_token]),
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       description: 'App Store Connect API Token; it is hash generated by app_store_connect_api_token action',
                                       type: Hash,
                                       optional: true,
                                       conflicting_options: [:api_key, :api_key_path]),
          FastlaneCore::ConfigItem.new(key: :username,
                                       short_option: "-u",
                                       env_name: "DOWNLOAD_DSYMS_USERNAME",
                                       description: "Your Apple ID Username for App Store Connect",
                                       default_value: user,
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :app_identifier,
                                       short_option: "-a",
                                       env_name: "DOWNLOAD_DSYMS_APP_IDENTIFIER",
                                       description: "The bundle identifier of your app",
                                       optional: false,
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier),
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :team_id,
                                       short_option: "-k",
                                       env_name: "DOWNLOAD_DSYMS_TEAM_ID",
                                       description: "The ID of your App Store Connect team if you're in multiple teams",
                                       optional: true,
                                       skip_type_validation: true, # as we also allow integers, which we convert to strings anyway
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_id),
                                       default_value_dynamic: true,
                                       verify_block: proc do |value|
                                         ENV["FASTLANE_ITC_TEAM_ID"] = value.to_s
                                       end),
          FastlaneCore::ConfigItem.new(key: :team_name,
                                       short_option: "-e",
                                       env_name: "DOWNLOAD_DSYMS_TEAM_NAME",
                                       description: "The name of your App Store Connect team if you're in multiple teams",
                                       optional: true,
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_name),
                                       default_value_dynamic: true,
                                       verify_block: proc do |value|
                                         ENV["FASTLANE_ITC_TEAM_NAME"] = value.to_s
                                       end),
          FastlaneCore::ConfigItem.new(key: :platform,
                                       short_option: "-p",
                                       env_name: "DOWNLOAD_DSYMS_PLATFORM",
                                       description: "The app platform for dSYMs you wish to download (ios, appletvos)",
                                       default_value: :ios),
          FastlaneCore::ConfigItem.new(key: :version,
                                       short_option: "-v",
                                       env_name: "DOWNLOAD_DSYMS_VERSION",
                                       description: "The app version for dSYMs you wish to download, pass in 'latest' to download only the latest build's dSYMs or 'live' to download only the live version dSYMs",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :build_number,
                                       short_option: "-b",
                                       env_name: "DOWNLOAD_DSYMS_BUILD_NUMBER",
                                       description: "The app build_number for dSYMs you wish to download",
                                       optional: true,
                                       skip_type_validation: true), # as we also allow integers, which we convert to strings anyway
          FastlaneCore::ConfigItem.new(key: :min_version,
                                       short_option: "-m",
                                       env_name: "DOWNLOAD_DSYMS_MIN_VERSION",
                                       description: "The minimum app version for dSYMs you wish to download",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :after_uploaded_date,
                                       short_option: "-d",
                                       env_name: "DOWNLOAD_DSYMS_AFTER_UPLOADED_DATE",
                                       description: "The uploaded date after which you wish to download dSYMs",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :output_directory,
                                       short_option: "-s",
                                       env_name: "DOWNLOAD_DSYMS_OUTPUT_DIRECTORY",
                                       description: "Where to save the download dSYMs, defaults to the current path",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :wait_for_dsym_processing,
                                       short_option: "-w",
                                       env_name: "DOWNLOAD_DSYMS_WAIT_FOR_DSYM_PROCESSING",
                                       description: "Wait for dSYMs to process",
                                       optional: true,
                                       default_value: false,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :wait_timeout,
                                       short_option: "-t",
                                       env_name: "DOWNLOAD_DSYMS_WAIT_TIMEOUT",
                                       description: "Number of seconds to wait for dSYMs to process",
                                       optional: true,
                                       default_value: 300,
                                       type: Integer)
        ]
      end

      def self.output
        [
          ['DSYM_PATHS', 'An array to all the zipped dSYM files'],
          ['DSYM_LATEST_UPLOADED_DATE', 'Date of the most recent uploaded time of successfully downloaded dSYM files']
        ]
      end

      def self.return_value
        nil
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        [:ios, :appletvos].include?(platform)
      end

      def self.example_code
        [
          'download_dsyms',
          'download_dsyms(version: "1.0.0", build_number: "345")',
          'download_dsyms(version: "1.0.1", build_number: 42)',
          'download_dsyms(version: "live")',
          'download_dsyms(min_version: "1.2.3")',
          'download_dsyms(after_uploaded_date: "2020-09-11T19:00:00+01:00")'
        ]
      end

      def self.category
        :app_store_connect
      end
    end
  end
end
