module Fastlane
  module Actions
    module SharedValues
      DSYM_PATHS = :DSYM_PATHS
    end

    class DownloadDsymsAction < Action
      # rubocop:disable Metrics/PerceivedComplexity
      def self.run(params)
        require 'spaceship'
        require 'net/http'

        UI.message("Login to iTunes Connect (#{params[:username]})")
        Spaceship::Tunes.login(params[:username])
        Spaceship::Tunes.select_team
        UI.message("Login successful")

        # Get App
        app = Spaceship::Application.find(params[:app_identifier])
        unless app
          UI.user_error!("Could not find app with bundle identifier '#{params[:app_identifier]}' on account #{params[:username]}")
        end

        # Process options
        version = params[:version]
        build_number = params[:build_number]
        platform = params[:platform]
        output_directory = params[:output_directory]

        # Set version if it is latest
        if version == 'latest'
          # Try to grab the edit version first, else fallback to live version
          UI.message("Looking for latest version...")
          latest_version = app.edit_version(platform: platform) || app.live_version(platform: platform)

          UI.user_error!("Could not find latest version for your app, please try setting a specific version") if latest_version.version.nil?

          version = latest_version.version
          build_number = latest_version.build_version
        end

        # Make sure output_directory has a slash on the end
        if output_directory && !output_directory.end_with?('/')
          output_directory += '/'
        end

        # Write a nice message
        message = []
        message << "Looking for dSYM files for #{params[:app_identifier]}"
        message << "v#{version}" if version
        message << "(#{build_number})" if build_number
        UI.message(message.join(" "))

        # Loop through all app versions and download their dSYM
        app.all_build_train_numbers(platform: platform).each do |train_number|
          if version && version != train_number
            next
          end
          app.all_builds_for_train(train: train_number, platform: platform).each do |build|
            if build_number && build.build_version != build_number
              next
            end

            begin
              # need to call reload here or dsym_url is nil
              build.reload
              download_url = build.dsym_url
            rescue Spaceship::TunesClient::ITunesConnectError => ex
              UI.error("Error accessing dSYM file for build\n\n#{build}\n\nException: #{ex}")
            end

            if download_url
              result = self.download(download_url)
              path   = write_dsym(result, app.bundle_id, train_number, build.build_version, output_directory)
              UI.success("🔑  Successfully downloaded dSYM file for #{train_number} - #{build.build_version} to '#{path}'")

              Actions.lane_context[SharedValues::DSYM_PATHS] ||= []
              Actions.lane_context[SharedValues::DSYM_PATHS] << File.expand_path(path)
              break if build_number
            else
              UI.message("No dSYM URL for #{build.build_version} (#{build.train_version})")
            end
          end
        end

        if (Actions.lane_context[SharedValues::DSYM_PATHS] || []).count == 0
          UI.error("No dSYM files found on iTunes Connect - this usually happens when no recompling happened yet")
        end
      end
      # rubocop:enable Metrics/PerceivedComplexity

      def self.write_dsym(data, bundle_id, train_number, build_number, output_directory)
        file_name = "#{bundle_id}-#{train_number}-#{build_number}.dSYM.zip"
        if output_directory
          file_name = output_directory + file_name
        end
        File.binwrite(file_name, data)
        file_name
      end

      def self.download(url)
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == "https")
        res = http.get(uri.request_uri)
        res.body
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Download dSYM files from Apple iTunes Connect for Bitcode apps"
      end

      def self.details
        [
          "This action downloads dSYM files from Apple iTunes Connect after",
          "the ipa got re-compiled by Apple. Useful if you have Bitcode enabled",
          "```ruby",
          "lane :refresh_dsyms do",
          "  download_dsyms                  # Download dSYM files from iTC",
          "  upload_symbols_to_crashlytics   # Upload them to Crashlytics",
          "  clean_build_artifacts           # Delete the local dSYM files",
          "end",
          "```"
        ].join("\n")
      end

      def self.available_options
        user = CredentialsManager::AppfileConfig.try_fetch_value(:itunes_connect_id)
        user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

        [
          FastlaneCore::ConfigItem.new(key: :username,
                                       short_option: "-u",
                                       env_name: "DOWNLOAD_DSYMS_USERNAME",
                                       description: "Your Apple ID Username for iTunes Connect",
                                       default_value: user),
          FastlaneCore::ConfigItem.new(key: :app_identifier,
                                       short_option: "-a",
                                       env_name: "DOWNLOAD_DSYMS_APP_IDENTIFIER",
                                       description: "The bundle identifier of your app",
                                       optional: false,
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)),
          FastlaneCore::ConfigItem.new(key: :team_id,
                                       short_option: "-k",
                                       env_name: "DOWNLOAD_DSYMS_TEAM_ID",
                                       description: "The ID of your iTunes Connect team if you're in multiple teams",
                                       optional: true,
                                       is_string: false, # as we also allow integers, which we convert to strings anyway
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_id),
                                       verify_block: proc do |value|
                                         ENV["FASTLANE_ITC_TEAM_ID"] = value.to_s
                                       end),
          FastlaneCore::ConfigItem.new(key: :team_name,
                                       short_option: "-e",
                                       env_name: "DOWNLOAD_DSYMS_TEAM_NAME",
                                       description: "The name of your iTunes Connect team if you're in multiple teams",
                                       optional: true,
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_name),
                                       verify_block: proc do |value|
                                         ENV["FASTLANE_ITC_TEAM_NAME"] = value.to_s
                                       end),
          FastlaneCore::ConfigItem.new(key: :platform,
                                       short_option: "-p",
                                       env_name: "DOWNLOAD_DSYMS_PLATFORM",
                                       description: "The app platform for dSYMs you wish to download (ios, appletvos)",
                                       optional: true,
                                       default_value: :ios),
          FastlaneCore::ConfigItem.new(key: :version,
                                       short_option: "-v",
                                       env_name: "DOWNLOAD_DSYMS_VERSION",
                                       description: "The app version for dSYMs you wish to download, pass in 'latest' to download only the latest build's dSYMs",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :build_number,
                                       short_option: "-b",
                                       env_name: "DOWNLOAD_DSYMS_BUILD_NUMBER",
                                       description: "The app build_number for dSYMs you wish to download",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :output_directory,
                                       short_option: "-s",
                                       env_name: "DOWNLOAD_DSYMS_OUTPUT_DIRECTORY",
                                       description: "Where to save the download dSYMs, defaults to the current path",
                                       optional: true)
        ]
      end

      def self.output
        [
          ['DSYM_PATHS', 'An array to all the zipped dSYM files']
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
          'download_dsyms(version: "1.0.0", build_number: "345")'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
