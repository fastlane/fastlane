# Workaround, since hockeyapp.rb from shenzhen includes the code for commander
def command(_param)
end

module Fastlane
  module Actions
    module SharedValues
      HOCKEY_DOWNLOAD_LINK = :HOCKEY_DOWNLOAD_LINK
      HOCKEY_BUILD_INFORMATION = :HOCKEY_BUILD_INFORMATION # contains all keys/values from the HockeyApp API, like :title, :bundle_identifier
    end

    class HockeyAction < Action
      def self.run(options)
        # Available options: http://support.hockeyapp.net/kb/api/api-versions#upload-version

        require 'shenzhen'
        require 'shenzhen/plugins/hockeyapp'

        if options[:dsym]
          dsym_filename = options[:dsym]
        else
          dsym_path = options[:ipa].gsub('ipa', 'app.dSYM.zip')
          if File.exist?(dsym_path)
            dsym_filename = dsym_path
          else
            Helper.log.info "Symbols not found on path #{File.expand_path(dsym_path)}. Crashes won't be symbolicated properly".yellow
            dsym_filename = nil
          end
        end

        raise "Symbols on path '#{File.expand_path(dsym_filename)}' not found".red if dsym_filename && !File.exist?(dsym_filename)

        Helper.log.info 'Starting with ipa upload to HockeyApp... this could take some time.'.green

        client = Shenzhen::Plugins::HockeyApp::Client.new(options[:api_token])

        values = options.values
        values[:dsym_filename] = dsym_filename
        values[:notes_type] = options[:notes_type]

        return values if Helper.test?

        ipa_filename = options[:ipa]
        ipa_filename = nil if options[:upload_dsym_only]

        response = client.upload_build(ipa_filename, values)
        case response.status
        when 200...300
          url = response.body['public_url']

          Actions.lane_context[SharedValues::HOCKEY_DOWNLOAD_LINK] = url
          Actions.lane_context[SharedValues::HOCKEY_BUILD_INFORMATION] = response.body

          Helper.log.info "Public Download URL: #{url}" if url
          Helper.log.info 'Build successfully uploaded to HockeyApp!'.green
        else
          raise "Error when trying to upload ipa to HockeyApp: #{response.body}".red
        end
      end

      def self.description
        "Upload a new build to HockeyApp"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "FL_HOCKEY_API_TOKEN",
                                       description: "API Token for Hockey Access",
                                       verify_block: proc do |value|
                                         raise "No API token for Hockey given, pass using `api_token: 'token'`".red unless value and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :ipa,
                                       env_name: "FL_HOCKEY_IPA",
                                       description: "Path to your IPA file. Optional if you use the `gym` or `xcodebuild` action. For Mac zip the .app. For Android provide path to .apk file",
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
                                       verify_block: proc do |value|
                                         raise "Couldn't find ipa file at path '#{value}'".red unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :dsym,
                                       env_name: "FL_HOCKEY_DSYM",
                                       description: "Path to your symbols file. For iOS and Mac provide path to app.dSYM.zip. For Android provide path to mappings.txt file",
                                       default_value: Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH],
                                       optional: true,
                                       verify_block: proc do |value|
                                         # validation is done in the action
                                       end),
          FastlaneCore::ConfigItem.new(key: :notes,
                                       env_name: "FL_HOCKEY_NOTES",
                                       description: "Beta Notes",
                                       default_value: Actions.lane_context[SharedValues::FL_CHANGELOG] || "No changelog given"),
          FastlaneCore::ConfigItem.new(key: :notify,
                                       env_name: "FL_HOCKEY_NOTIFY",
                                       description: "Notify testers? 1 for yes",
                                       default_value: "1"),
          FastlaneCore::ConfigItem.new(key: :status,
                                       env_name: "FL_HOCKEY_STATUS",
                                       description: "Download status: 1 = No user can download; 2 = Available for download",
                                       default_value: "2"),
          FastlaneCore::ConfigItem.new(key: :notes_type,
                                      env_name: "FL_HOCKEY_NOTES_TYPE",
                                      description: "Notes type for your :notes, 0 = Textile, 1 = Markdown (default)",
                                      default_value: "1"),
          FastlaneCore::ConfigItem.new(key: :release_type,
                                      env_name: "FL_HOCKEY_RELEASE_TYPE",
                                      description: "Release type of the app: 0 = Beta (default), 1 = Store, 2 = Alpha, 3 = Enterprise",
                                      default_value: "0"),
          FastlaneCore::ConfigItem.new(key: :mandatory,
                                      env_name: "FL_HOCKEY_MANDATORY",
                                      description: "Set to 1 to make this update mandatory",
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
          FastlaneCore::ConfigItem.new(key: :public_identifier,
                                      env_name: "FL_HOCKEY_PUBLIC_IDENTIFIER",
                                      description: "Public identifier of the app you are targeting, usually you won't need this value",
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
                                      is_string: false,
                                      default_value: false),
          FastlaneCore::ConfigItem.new(key: :owner_id,
                                      env_name: "FL_HOCKEY_OWNER_ID",
                                      description: "ID for the owner of the app",
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
        "KrauseFx"
      end

      def self.is_supported?(platform)
        [:ios, :mac, :android].include? platform
      end
    end
  end
end
