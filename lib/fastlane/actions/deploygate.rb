# TODO: Workaround, since deploygate.rb from shenzhen includes the code for commander
def command(param)
end

module Fastlane
  module Actions
    module SharedValues
      DEPLOYGATE_URL = :DEPLOYGATE_URL
      DEPLOYGATE_REVISION = :DEPLOYGATE_REVISION # auto increment revision number
      DEPLOYGATE_APP_INFO = :DEPLOYGATE_APP_INFO # contains app revision, bundle identifier, etc.
    end

    class DeploygateAction
      DEPLOYGATE_URL_BASE = 'https://deploygate.com'

      def self.run(params)
        require 'shenzhen'
        require 'shenzhen/plugins/deploygate'

        # Available options: https://deploygate.com/docs/api
        options = {
          visibility: 'private',
          ipa: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
        }.merge(params.first)
        assert_options!(options)

        Helper.log.info "Starting with ipa upload to DeployGate... this could take some time.".green
        client = Shenzhen::Plugins::DeployGate::Client.new(options[:api_token], options[:username])

        return if Helper.is_test?

        response = client.upload_build(options[:ipa], options)
        if parse_response(response)
          Helper.log.info "DeployGate URL: #{Actions.lane_context[SharedValues::DEPLOYGATE_URL]}"
          Helper.log.info "Build successfully uploaded to DeployGate as revision \##{Actions.lane_context[SharedValues::DEPLOYGATE_REVISION]}!".green
        else
          raise "Error when trying to upload ipa to DeployGate".red
        end
      end

      private

      def self.assert_options!(options)
        raise "No API Token for DeployGate given, pass using `api_token: 'token'`".red unless options[:api_token].to_s.length > 0
        raise "No Username for app given, pass using `username: 'username'`".red unless options[:username].to_s.length > 0
        raise "No IPA file given or found, pass using `ipa: 'path.ipa'`".red unless options[:ipa]
        raise "IPA file on path '#{File.expand_path(options[:ipa])}' not found".red unless File.exists?(options[:ipa])
      end

      def self.parse_response(response)
        if response.body && response.body.key?('error')
          unless response.body['error']
            res = response.body['results']
            url = DEPLOYGATE_URL_BASE + res['path']

            Actions.lane_context[SharedValues::DEPLOYGATE_URL] = url
            Actions.lane_context[SharedValues::DEPLOYGATE_REVISION] = res['revision']
            Actions.lane_context[SharedValues::DEPLOYGATE_APP_INFO] = res
          else
            Helper.log.error "Error uploading to DeployGate: #{response.body['message']}"
            help_message(response)
            return
          end
        else
          Helper.log.fatal "Error uploading to DeployGate: #{response.body}"
          return
        end
        true
      end

      def self.help_message(response)
        case response.body['message']
          when 'you are not authenticated'
            Helper.log.error "Invalid API Token specified."
          when 'application create error: permit'
            Helper.log.error "Access denied: May be trying to upload to wrong user or updating app you join as a tester?"
          when 'application create error: limit'
            Helper.log.error "Plan limit: You have reached to the limit of current plan or your plan was expired."
        end
      end
    end
  end
end