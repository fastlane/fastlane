module Fastlane
  module Actions
    module SharedValues
      TESTFAIRY_BUILD_URL = :TESTFAIRY_BUILD_URL
    end

    # To share this integration with the other fastlane users:
    # - Fork https://github.com/KrauseFx/fastlane
    # - Clone the forked repository
    # - Move this integration into lib/fastlane/actions
    # - Commit, push and submit the pull request

    class TestfairyAction < Action
      def self.run(params)
        require 'shenzhen'
        require 'shenzhen/plugins/testfairy'

        Helper.log.info 'Starting with ipa upload to TestFairy...'.green

        client = Shenzhen::Plugins::TestFairy::Client.new(
          params[:api_key]
        )

        return params[:ipa] if Helper.test?

        response = client.upload_build(params[:ipa], params.values)
        if parse_response(response)
          Helper.log.info "Build URL: #{Actions.lane_context[SharedValues::TESTFAIRY_BUILD_URL]}".green
          Helper.log.info "Build successfully uploaded to TestFairy.".green
        else
          raise 'Error when trying to upload ipa to TestFairy'.red
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.parse_response(response)
        if response.body && response.body.key?('status') && response.body['status'] == 'ok'
          build_url = response.body['build_url']

          Actions.lane_context[SharedValues::TESTFAIRY_BUILD_URL] = build_url

          return true
        else
          Helper.log.fatal "Error uploading to TestFairy: #{response.body}".red

          return false
        end
      end
      private_class_method :parse_response

      def self.description
        'Upload a new build to TestFairy'
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :api_key,
                                       env_name: "FL_TESTFAIRY_API_KEY", # The name of the environment variable
                                       description: "API Key for TestFairy", # a short description of this parameter
                                       verify_block: proc do |value|
                                         raise "No API key for TestFairy given, pass using `api_key: 'key'`".red unless (value and not value.empty?)
                                           # raise "Couldn't find file at path '#{value}'".red unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :ipa,
                                       env_name: 'TESTFAIRY_IPA_PATH',
                                       description: 'Path to your IPA file. Optional if you use the `gym` or `xcodebuild` action',
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
                                       verify_block: proc do |value|
                                         raise "Couldn't find ipa file at path '#{value}'".red unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :comment,
                                       env_name: "FL_TESTFAIRY_COMMENT",
                                       description: "Additional release notes for this upload. This text will be added to email notifications",
                                       default_value: 'No comment provided') # the default value if the user didn't provide one
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['TESTFAIRY_BUILD_URL', 'URL of the newly uploaded build']
        ]
      end

      def self.authors
        ["taka0125"]
      end

      def self.is_supported?(platform)
        # you can do things like
        #
        #  true
        #
        #  platform == :ios
        #
        #  [:ios, :mac].include?(platform)
        #
        platform == :ios
      end
    end
  end
end
