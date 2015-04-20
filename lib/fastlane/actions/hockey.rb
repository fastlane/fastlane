# TODO: Workaround, since hockeyapp.rb from shenzhen includes the code for commander
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
        require 'pry'; binding.pry
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
          end
        end

        raise "Symbols on path '#{File.expand_path(dsym_filename)}' not found".red if (dsym_filename &&
                                                                                                !File.exist?(dsym_filename))

        Helper.log.info 'Starting with ipa upload to HockeyApp... this could take some time.'.green

        client = Shenzhen::Plugins::HockeyApp::Client.new(options[:api_token])

        return if Helper.test?

        response = client.upload_build(options[:ipa], options)
        case response.status
          when 200...300
            url = response.body['public_url']

            Actions.lane_context[SharedValues::HOCKEY_DOWNLOAD_LINK] = url
            Actions.lane_context[SharedValues::HOCKEY_BUILD_INFORMATION] = response.body

            Helper.log.info "Public Download URL: #{url}" if url
            Helper.log.info 'Build successfully uploaded to HockeyApp!'.green
          else
            Helper.log.fatal "Error uploading to HockeyApp: #{response.body}"
            raise 'Error when trying to upload ipa to HockeyApp'.red
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
                                       verify_block: Proc.new do |value|
                                          raise "No API token for Hockey given, pass using `api_token: 'token'`".red unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :ipa,
                                       env_name: "FL_HOCKEY_IPA",
                                       description: "Path to your IPA file. Optional if you use the `ipa` or `xcodebuild` action",
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
                                       verify_block: Proc.new do |value|
                                        raise "Couldn't find ipa file at path '#{value}'".red unless File.exists?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :dsym,
                                       env_name: "FL_HOCKEY_DSYM",
                                       description: "Path to your DSYM file",
                                       optional: true,
                                       verify_block: Proc.new do |value|
                                        # validation is done in the action
                                       end),
          FastlaneCore::ConfigItem.new(key: :notes,
                                       env_name: "FL_HOCKEY_NOTES",
                                       description: "Beta Notes",
                                       default_value: "No changelog given"),
          FastlaneCore::ConfigItem.new(key: :notify,
                                       env_name: "FL_HOCKEY_NOTIFY",
                                       description: "Notify testers? 1 for yes",
                                       default_value: 1),
          FastlaneCore::ConfigItem.new(key: :status,
                                       env_name: "FL_HOCKEY_STATUS",
                                       description: "Download status: 1 = No user can download; 2 = Available for download",
                                       default_value: "2")
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
        platform == :ios
      end
    end
  end
end
