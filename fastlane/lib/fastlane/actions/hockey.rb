module Fastlane
  module Actions
    module SharedValues
      HOCKEY_DOWNLOAD_LINK = :HOCKEY_DOWNLOAD_LINK
      HOCKEY_BUILD_INFORMATION = :HOCKEY_BUILD_INFORMATION # contains all keys/values from the HockeyApp API, like :title, :bundle_identifier
    end

    # rubocop:disable Metrics/ClassLength
    class HockeyAction < Action
      def self.connection(options)
        require 'faraday'
        require 'faraday_middleware'

        base_url = options.delete(:bypass_cdn) ? "https://rink.hockeyapp.net" : "https://upload.hockeyapp.net"
        foptions = {
          url: base_url
        }
        Faraday.new(foptions) do |builder|
          builder.request(:multipart)
          builder.request(:url_encoded)
          builder.response(:json, content_type: /\bjson$/)
          builder.use(FaradayMiddleware::FollowRedirects)
          builder.adapter(:net_http)
        end
      end

      def self.upload(api_token, ipa, options)
        create_update = options.delete(:create_update)

        if create_update
          self.create_and_update_build(api_token, ipa, options)
        else
          self.upload_build(api_token, ipa, options)
        end
      end

      # Uses https://support.hockeyapp.net/kb/api/api-versions#upload-version if a `public_identifier` was specified
      # otherwise https://support.hockeyapp.net/kb/api/api-apps#upload-app
      def self.upload_build(api_token, ipa, options)
        connection = self.connection(options)

        options[:ipa] = Faraday::UploadIO.new(ipa, 'application/octet-stream') if ipa && File.exist?(ipa)

        dsym_filename = options.delete(:dsym_filename)
        if dsym_filename
          options[:dsym] = Faraday::UploadIO.new(dsym_filename, 'application/octet-stream')
        end

        connection.post do |req|
          req.options.timeout = options.delete(:timeout)
          if options[:public_identifier].nil?
            req.url("/api/2/apps/upload")
          else
            req.url("/api/2/apps/#{options.delete(:public_identifier)}/app_versions/upload")
          end
          req.headers['X-HockeyAppToken'] = api_token
          req.body = options
        end
      end

      # Uses https://support.hockeyapp.net/kb/api/api-versions#create-version
      # and https://support.hockeyapp.net/kb/api/api-versions#update-version
      # to upload a build
      def self.create_and_update_build(api_token, ipa, options)
        [:public_identifier, :bundle_short_version, :bundle_version].each do |key|
          UI.user_error!("To use the 'create_update' upload mechanism you need to pass the '#{key.to_sym}' option.") unless options[key]
        end
        # https://support.hockeyapp.net/discussions/problems/33355-is-uploadhockeyappnet-available-for-general-use
        # GET requests are cached on CDN, so bypass it
        options[:bypass_cdn] = true
        connection = self.connection(options)

        options.delete(:ipa)
        options.delete(:apk)
        app_id = options.delete(:public_identifier)

        ipaio = Faraday::UploadIO.new(ipa, 'application/octet-stream') if ipa && File.exist?(ipa)
        dsym = options.delete(:dsym)

        if dsym
          dsym_io = Faraday::UploadIO.new(dsym, 'application/octet-stream') if dsym && File.exist?(dsym)
        end

        # https://support.hockeyapp.net/discussions/problems/83559
        # Should not set status to "2" (downloadable) until after the app is uploaded, so allow the caller
        # to specify a different status for the `create` step
        update_status = options[:status]
        options[:status] = options[:create_status]

        response = connection.get do |req|
          req.url("/api/2/apps/#{app_id}/app_versions/new")
          req.headers['X-HockeyAppToken'] = api_token
          req.body = options
        end

        case response.status
        when 200...300
          app_version_id = response.body['id']
          UI.message("successfully created version with id #{app_version_id}")
        else
          UI.user_error!("Error trying to create app version:  #{response.status} - #{response.body}")
        end

        options[:ipa] = ipaio

        if dsym
          options[:dsym] = dsym_io
        end

        options[:status] = update_status

        connection.put do |req|
          req.options.timeout = options.delete(:timeout)
          req.url("/api/2/apps/#{app_id}/app_versions/#{app_version_id}")
          req.headers['X-HockeyAppToken'] = api_token
          req.body = options
        end
      end

      def self.run(options)
        build_file = [
          options[:ipa],
          options[:apk]
        ].detect { |e| !e.to_s.empty? }

        if options[:dsym]
          dsym_filename = options[:dsym]
        else

          if build_file.nil?
            UI.user_error!("You have to provide a build file (params 'apk' or 'ipa')")
          end

          if options[:ipa].to_s.end_with?(".ipa")
            dsym_path = options[:ipa].to_s.gsub('.ipa', '.app.dSYM.zip')
            if File.exist?(dsym_path)
              dsym_filename = dsym_path
            else
              UI.important("Symbols not found on path #{File.expand_path(dsym_path)}. Crashes won't be symbolicated properly")
              dsym_filename = nil
            end
          end
        end

        UI.user_error!("Symbols on path '#{File.expand_path(dsym_filename)}' not found") if dsym_filename && !File.exist?(dsym_filename)

        if options[:upload_dsym_only]
          UI.success('Starting with dSYM upload to HockeyApp... this could take some time.')
        else
          UI.success('Starting with file(s) upload to HockeyApp... this could take some time.')
        end

        values = options.values
        values[:dsym_filename] = dsym_filename
        values[:notes_type] = options[:notes_type]

        api_token = values.delete(:api_token)

        values.delete_if { |k, v| v.nil? }

        return values if Helper.test?

        ipa_filename = build_file
        ipa_filename = nil if options[:upload_dsym_only]

        response = self.upload(api_token, ipa_filename, values)
        case response.status
        when 200...300
          url = response.body['public_url']

          Actions.lane_context[SharedValues::HOCKEY_DOWNLOAD_LINK] = url
          Actions.lane_context[SharedValues::HOCKEY_BUILD_INFORMATION] = response.body

          UI.message("Public Download URL: #{url}") if url
          UI.success('Build successfully uploaded to HockeyApp!')
        else
          if response.body.to_s.include?("App could not be created")
            UI.user_error!("Hockey has an issue processing this app. Please confirm that an app in Hockey matches this IPA's bundle ID or that you are using the correct API upload token. If error persists, please provide the :public_identifier option from the HockeyApp website. More information https://github.com/fastlane/fastlane/issues/400")
          else
            UI.user_error!("Error when trying to upload file(s) to HockeyApp: #{response.status} - #{response.body}")
          end
        end
      end

      def self.description
        "Refer to [App Center](https://github.com/Microsoft/fastlane-plugin-appcenter/)"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :apk,
                                       env_name: "FL_HOCKEY_APK",
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
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "FL_HOCKEY_API_TOKEN",
                                       sensitive: true,
                                       description: "API Token for Hockey Access",
                                       verify_block: proc do |value|
                                         UI.user_error!("No API token for Hockey given, pass using `api_token: 'token'`") unless value && !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :ipa,
                                       env_name: "FL_HOCKEY_IPA",
                                       description: "Path to your IPA file. Optional if you use the _gym_ or _xcodebuild_ action. For Mac zip the .app. For Android provide path to .apk file. In addition you could use this to upload .msi, .zip, .pkg, etc if you use the 'create_update' mechanism",
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
                                       default_value_dynamic: true,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find ipa file at path '#{value}'") unless File.exist?(value)
                                       end,
                                       conflicting_options: [:apk],
                                       conflict_block: proc do |value|
                                         UI.user_error!("You can't use 'ipa' and '#{value.key}' options in one run")
                                       end),
          FastlaneCore::ConfigItem.new(key: :dsym,
                                       env_name: "FL_HOCKEY_DSYM",
                                       description: "Path to your symbols file. For iOS and Mac provide path to app.dSYM.zip. For Android provide path to mappings.txt file",
                                       default_value: Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH],
                                       default_value_dynamic: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :create_update,
                                       env_name: "FL_HOCKEY_CREATE_UPDATE",
                                       description: "Set true if you want to create then update your app as opposed to just upload it."\
                                         " You will need the 'public_identifier', 'bundle_version' and 'bundle_short_version'",
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :notes,
                                       env_name: "FL_HOCKEY_NOTES",
                                       description: "Beta Notes",
                                       default_value: Actions.lane_context[SharedValues::FL_CHANGELOG] || "No changelog given",
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :notify,
                                       env_name: "FL_HOCKEY_NOTIFY",
                                       description: "Notify testers? \"1\" for yes",
                                       default_value: "1"),
          FastlaneCore::ConfigItem.new(key: :status,
                                       env_name: "FL_HOCKEY_STATUS",
                                       description: "Download status: \"1\" = No user can download; \"2\" = Available for download (only possible with full-access token)",
                                       default_value: "2"),
          FastlaneCore::ConfigItem.new(key: :create_status,
                                       env_name: "FL_HOCKEY_CREATE_STATUS",
                                       description: "Download status for initial version creation when create_update is true: \"1\" = No user can download; \"2\" = Available for download (only possible with full-access token)",
                                       default_value: "2"),
          FastlaneCore::ConfigItem.new(key: :notes_type,
                                      env_name: "FL_HOCKEY_NOTES_TYPE",
                                      description: "Notes type for your :notes, \"0\" = Textile, \"1\" = Markdown (default)",
                                      default_value: "1"),
          FastlaneCore::ConfigItem.new(key: :release_type,
                                      env_name: "FL_HOCKEY_RELEASE_TYPE",
                                      description: "Release type of the app: \"0\" = Beta (default), \"1\" = Store, \"2\" = Alpha, \"3\" = Enterprise",
                                      default_value: "0"),
          FastlaneCore::ConfigItem.new(key: :mandatory,
                                      env_name: "FL_HOCKEY_MANDATORY",
                                      description: "Set to \"1\" to make this update mandatory",
                                      default_value: "0"),
          FastlaneCore::ConfigItem.new(key: :teams,
                                      env_name: "FL_HOCKEY_TEAMS",
                                      description: "Comma separated list of team ID numbers to which this build will be restricted",
                                      optional: true),
          FastlaneCore::ConfigItem.new(key: :users,
                                      env_name: "FL_HOCKEY_USERS",
                                      description: "Comma separated list of user ID numbers to which this build will be restricted",
                                      optional: true),
          FastlaneCore::ConfigItem.new(key: :tags,
                                      env_name: "FL_HOCKEY_TAGS",
                                      description: "Comma separated list of tags which will receive access to the build",
                                      optional: true),
          FastlaneCore::ConfigItem.new(key: :bundle_short_version,
                                      env_name: "FL_HOCKEY_BUNDLE_SHORT_VERSION",
                                      description: "The bundle_short_version of your application, required when using `create_update`",
                                      optional: true),
          FastlaneCore::ConfigItem.new(key: :bundle_version,
                                      env_name: "FL_HOCKEY_BUNDLE_VERSION",
                                      description: "The bundle_version of your application, required when using `create_update`",
                                      optional: true),
          FastlaneCore::ConfigItem.new(key: :public_identifier,
                                      env_name: "FL_HOCKEY_PUBLIC_IDENTIFIER",
                                      description: "App id of the app you are targeting, usually you won't need this value. Required, if `upload_dsym_only` set to `true`",
                                      optional: true),
          FastlaneCore::ConfigItem.new(key: :commit_sha,
                                      env_name: "FL_HOCKEY_COMMIT_SHA",
                                      description: "The Git commit SHA for this build",
                                      optional: true),
          FastlaneCore::ConfigItem.new(key: :repository_url,
                                      env_name: "FL_HOCKEY_REPOSITORY_URL",
                                      description: "The URL of your source repository",
                                      optional: true),
          FastlaneCore::ConfigItem.new(key: :build_server_url,
                                      env_name: "FL_HOCKEY_BUILD_SERVER_URL",
                                      description: "The URL of the build job on your build server",
                                      optional: true),
          FastlaneCore::ConfigItem.new(key: :upload_dsym_only,
                                      env_name: "FL_HOCKEY_UPLOAD_DSYM_ONLY",
                                      description: "Flag to upload only the dSYM file to hockey app",
                                      type: Boolean,
                                      default_value: false),
          FastlaneCore::ConfigItem.new(key: :owner_id,
                                      env_name: "FL_HOCKEY_OWNER_ID",
                                      description: "ID for the owner of the app",
                                      optional: true),
          FastlaneCore::ConfigItem.new(key: :strategy,
                                       env_name: "FL_HOCKEY_STRATEGY",
                                       description: "Strategy: 'add' = to add the build as a new build even if it has the same build number (default); 'replace' = to replace a build with the same build number",
                                       default_value: "add",
                                       verify_block: proc do |value|
                                         UI.user_error!("Invalid value '#{value}' for key 'strategy'. Allowed values are 'add', 'replace'.") unless ['add', 'replace'].include?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :timeout,
                                      env_name: "FL_HOCKEY_TIMEOUT",
                                      description: "Request timeout in seconds",
                                      type: Integer,
                                      optional: true),
          FastlaneCore::ConfigItem.new(key: :bypass_cdn,
                                      env_name: "FL_HOCKEY_BYPASS_CDN",
                                      description: "Flag to bypass Hockey CDN when it uploads successfully but reports error",
                                      type: Boolean,
                                      default_value: false),
          FastlaneCore::ConfigItem.new(key: :dsa_signature,
                                      env_name: "FL_HOCKEY_DSA_SIGNATURE",
                                      description: "DSA signature for sparkle updates for macOS",
                                      default_value: "",
                                      optional: true)
        ]
      end

      def self.output
        [
          ['HOCKEY_DOWNLOAD_LINK', 'The newly generated download link for this build'],
          ['HOCKEY_BUILD_INFORMATION', 'contains all keys/values from the HockeyApp API, like :title, :bundle_identifier']
        ]
      end

      def self.author
        ["KrauseFx", "modzelewski", "lacostej"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.details
        [
          "HockeyApp will be no longer supported and will be transitioned into App Center on November 16, 2019.",
          "Please migrate over to [App Center](https://github.com/Microsoft/fastlane-plugin-appcenter/)",
          "",
          "Symbols will also be uploaded automatically if a `app.dSYM.zip` file is found next to `app.ipa`. In case it is located in a different place you can specify the path explicitly in the `:dsym` parameter.",
          "More information about the available options can be found in the [HockeyApp Docs](http://support.hockeyapp.net/kb/api/api-versions#upload-version)."
        ].join("\n")
      end

      def self.example_code
        [
          'hockey(
            api_token: "...",
            ipa: "./app.ipa",
            notes: "Changelog"
          )',
          'hockey(
            api_token: "...",
            create_update: true,
            public_identifier: "....",
            bundle_short_version: "1.0.2",
            bundle_version: "1.0.2.145",
            ipa: "./my.msi",
            notes: "Changelog"
          )',
          '# You can bypass the CDN if you are uploading to Hockey and receive an SSL error (which can happen on corporate firewalls)
          hockey(
            api_token: "...",
            ipa: "./app.ipa",
            notes: "Changelog",
            bypass_cdn: true
          )'
        ]
      end

      def self.category
        :deprecated
      end

      def self.deprecated_notes
        [
          "HockeyApp will be no longer supported and will be transitioned into App Center on November 16, 2019.",
          "Please migrate over to [App Center](https://github.com/Microsoft/fastlane-plugin-appcenter/)"
        ].join("\n")
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
