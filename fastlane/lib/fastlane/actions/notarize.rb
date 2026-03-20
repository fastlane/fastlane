module Fastlane
  module Actions
    class NotarizeAction < Action
      # rubocop:disable Metrics/PerceivedComplexity
      def self.run(params)
        package_path = params[:package]
        bundle_id = params[:bundle_id]
        skip_stapling = params[:skip_stapling]
        print_log = params[:print_log]
        verbose = params[:verbose]

        # Only set :api_key from SharedValues if :api_key_path isn't set (conflicting options)
        unless params[:api_key_path]
          params[:api_key] ||= Actions.lane_context[SharedValues::APP_STORE_CONNECT_API_KEY]
        end
        api_key = Spaceship::ConnectAPI::Token.from(hash: params[:api_key], filepath: params[:api_key_path])

        # Compress and read bundle identifier only for .app bundle.
        compressed_package_path = nil
        if File.extname(package_path) == '.app'
          compressed_package_path = "#{package_path}.zip"
          Actions.sh(
            "ditto -c -k --rsrc --keepParent \"#{package_path}\" \"#{compressed_package_path}\"",
            log: verbose
          )

          unless bundle_id
            info_plist_path = File.join(package_path, 'Contents', 'Info.plist')
            bundle_id = Actions.sh(
              "/usr/libexec/PlistBuddy -c \"Print :CFBundleIdentifier\" \"#{info_plist_path}\"",
              log: verbose
            ).strip
          end
        end

        UI.user_error!('Could not read bundle identifier, provide as a parameter') unless bundle_id

        notarytool(params, package_path, bundle_id, skip_stapling, print_log, verbose, api_key, compressed_package_path)
      end

      def self.notarytool(params, package_path, bundle_id, skip_stapling, print_log, verbose, api_key, compressed_package_path)
        temp_file = nil

        # Create authorization part of command with either API Key or Apple ID
        auth_parts = []
        if api_key
          # Writes key contents to temporary file for command
          require 'tempfile'
          temp_file = Tempfile.new
          api_key.write_key_to_file(temp_file.path)

          auth_parts << "--key #{temp_file.path}"
          auth_parts << "--key-id #{api_key.key_id}"
          auth_parts << "--issuer #{api_key.issuer_id}"
        else
          auth_parts << "--apple-id #{params[:username]}"
          auth_parts << "--password #{ENV['FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD']}"
          auth_parts << "--team-id #{params[:asc_provider]}"
        end

        # Submits package and waits for processing using `xcrun notarytool submit --wait`
        submit_parts = [
          "xcrun notarytool submit",
          (compressed_package_path || package_path).shellescape,
          "--output-format json",
          "--wait"
        ] + auth_parts

        if verbose
          submit_parts << "--verbose"
        end

        submit_command = submit_parts.join(' ')
        submit_response = Actions.sh(
          submit_command,
          log: verbose,
          error_callback: lambda { |msg|
            UI.error("Error polling for notarization info: #{msg}")
          }
        )

        notarization_info = JSON.parse(submit_response)

        # Staple
        submission_id = notarization_info["id"]
        case notarization_info['status']
        when 'Accepted'
          UI.success("Successfully uploaded package to notarization service with request identifier #{submission_id}")

          if skip_stapling
            UI.success("Successfully notarized artifact")
          else
            UI.message('Stapling package')

            self.staple(package_path, verbose)

            UI.success("Successfully notarized and stapled package")
          end
        when 'Invalid'
          if submission_id && print_log
            log_request_parts = [
              "xcrun notarytool log #{submission_id}"
            ] + auth_parts
            log_request_command = log_request_parts.join(' ')
            log_request_response = Actions.sh(
              log_request_command,
              log: verbose,
              error_callback: lambda { |msg|
                UI.error("Error requesting the notarization log: #{msg}")
              }
            )
            UI.user_error!("Could not notarize package with message '#{log_request_response}'")
          else
            UI.user_error!("Could not notarize package. To see the error, please set 'print_log' to true.")
          end
        else
          UI.crash!("Could not notarize package with status '#{notarization_info['status']}'")
        end
      ensure
        temp_file.delete if temp_file
      end

      def self.staple(package_path, verbose)
        Actions.sh(
          "xcrun stapler staple #{package_path.shellescape}",
          log: verbose
        )
      end

      def self.description
        'Notarizes a macOS app'
      end

      def self.authors
        ['zeplin']
      end

      def self.available_options
        username = CredentialsManager::AppfileConfig.try_fetch_value(:apple_dev_portal_id)
        username ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

        asc_provider = CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_id)

        [
          FastlaneCore::ConfigItem.new(key: :package,
                                       env_name: 'FL_NOTARIZE_PACKAGE',
                                       description: 'Path to package to notarize, e.g. .app bundle or disk image',
                                       verify_block: proc do |value|
                                         UI.user_error!("Could not find package at '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :skip_stapling,
                                       env_name: 'FL_NOTARIZE_SKIP_STAPLING',
                                       description: 'Do not staple the notarization ticket to the artifact; useful for single file executables and ZIP archives',
                                       optional: true,
                                       default_value: false,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :bundle_id,
                                       env_name: 'FL_NOTARIZE_BUNDLE_ID',
                                       description: 'Bundle identifier to uniquely identify the package',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :username,
                                       env_name: 'FL_NOTARIZE_USERNAME',
                                       description: 'Apple ID username',
                                       default_value: username,
                                       optional: true,
                                       conflicting_options: [:api_key_path, :api_key],
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :asc_provider,
                                       env_name: 'FL_NOTARIZE_ASC_PROVIDER',
                                       description: 'Provider short name for accounts associated with multiple providers',
                                       optional: true,
                                       default_value: asc_provider),
          FastlaneCore::ConfigItem.new(key: :print_log,
                                       env_name: 'FL_NOTARIZE_PRINT_LOG',
                                       description: 'Whether to print notarization log file, listing issues on failure and warnings on success',
                                       optional: true,
                                       default_value: false,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       env_name: 'FL_NOTARIZE_VERBOSE',
                                       description: 'Whether to log requests',
                                       optional: true,
                                       default_value: false,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :api_key_path,
                                       env_names: ['FL_NOTARIZE_API_KEY_PATH', "APP_STORE_CONNECT_API_KEY_PATH"],
                                       description: "Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)",
                                       optional: true,
                                       conflicting_options: [:username, :api_key],
                                       verify_block: proc do |value|
                                         UI.user_error!("API Key not found at '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :api_key,
                                       env_names: ['FL_NOTARIZE_API_KEY', "APP_STORE_CONNECT_API_KEY"],
                                       description: "Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-hash-option)",
                                       optional: true,
                                       conflicting_options: [:username, :api_key_path],
                                       sensitive: true,
                                       type: Hash)
        ]
      end

      def self.is_supported?(platform)
        platform == :mac
      end

      def self.category
        :code_signing
      end
    end
  end
end
