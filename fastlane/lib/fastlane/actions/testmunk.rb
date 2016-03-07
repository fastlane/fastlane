# How it works:
# You can run your functional calabash testcases on real ios hardware.
# Follow the steps to set up your free account on testmunk.com or see below.
# After tests are executed you will get an email with test results.
# An API extension to see test results directly in Jenkins is in the works.

# Setup
# 1) Create a free account on testmunk.com
# 2) Create an own project under your account (top right) after you are logged in. You will need to use this project name within your REST API upload path.
# 3) Upload testcases (features in calabash) over the testmunk REST API (http://docs.testmunk.com/en/latest/rest.html#upload-testcases).

module Fastlane
  module Actions
    class TestmunkAction < Action
      def self.run(config)
        Helper.log.info 'Testmunk: Uploading the .ipa and starting your tests'.green

        Helper.log.info 'Zipping features/ to features.zip'.green
        zipped_features_path = File.expand_path('features.zip')
        Actions.sh(%(zip -r "features" "features/"))

        response = system("curl -H 'Accept: application/vnd.testmunk.v1+json'" \
            " -F 'file=@#{config[:ipa]}' -F 'autoStart=true'" \
            " -F 'testcases=@#{zipped_features_path}'" \
            " -F 'email=#{config[:email]}'" \
            " https://#{config[:api]}@api.testmunk.com/apps/#{config[:app]}/testruns")

        if response
          Helper.log.info 'Your tests are being executed right now. Please wait for the mail with results and decide if you want to continue.'.green
        else
          raise 'Something went wrong while uploading your app to Testmunk'.red
        end
      end

      def self.description
        "Run tests on real devices using Testmunk"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :ipa,
                                       env_name: "TESTMUNK_IPA",
                                       description: "Path to IPA",
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
                                       verify_block: proc do |value|
                                         raise "Please pass to existing ipa" unless File.exist? value
                                       end),
          FastlaneCore::ConfigItem.new(key: :email,
                                       env_name: "TESTMUNK_EMAIL",
                                       description: "Your email address",
                                       verify_block: proc do |value|
                                         raise "Please pass your Testmunk email address using `ENV['TESTMUNK_EMAIL'] = 'value'`" unless value
                                       end),
          FastlaneCore::ConfigItem.new(key: :api,
                                       env_name: "TESTMUNK_API",
                                       description: "Testmunk API Key",
                                       verify_block: proc do |value|
                                         raise "Please pass your Testmunk API Key using `ENV['TESTMUNK_API'] = 'value'`" unless value
                                       end),
          FastlaneCore::ConfigItem.new(key: :app,
                                       env_name: "TESTMUNK_APP",
                                       description: "Testmunk App Name",
                                       verify_block: proc do |value|
                                         raise "Please pass your Testmunk app name using `ENV['TESTMUNK_APP'] = 'value'`" unless value
                                       end)
        ]
      end

      def self.author
        ["mposchen", "johannesberdin"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
