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
      def self.run(params)
        # Available options: http://support.hockeyapp.net/kb/api/api-versions#upload-version
        options = {
          notes: 'No changelog given',
          status: 2,
          notify: 1
        }.merge(params.first)

        options[:ipa] ||= Actions.lane_context[SharedValues::IPA_OUTPUT_PATH]
        options[:dsym] ||= Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH]

        require 'shenzhen'
        require 'shenzhen/plugins/hockeyapp'

        raise "No API Token for Hockey given, pass using `api_token: 'token'`".red unless options[:api_token].to_s.length > 0
        raise "No IPA file given or found, pass using `ipa: 'path.ipa'`".red unless options[:ipa]
        raise "IPA file on path '#{File.expand_path(options[:ipa])}' not found".red unless File.exist?(options[:ipa])

        if options[:dsym]
          options[:dsym_filename] = options[:dsym]
        else
          dsym_path = options[:ipa].gsub('ipa', 'app.dSYM.zip')
          if File.exist?(dsym_path)
            options[:dsym_filename] = dsym_path
          else
            Helper.log.info "Symbols not found on path #{File.expand_path(dsym_path)}. Crashes won't be symbolicated properly".yellow
          end
        end

        raise "Symbols on path '#{File.expand_path(options[:dsym_filename])}' not found".red if (options[:dsym_filename] &&
                                                                                                !File.exist?(options[:dsym_filename]))

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
    end
  end
end
