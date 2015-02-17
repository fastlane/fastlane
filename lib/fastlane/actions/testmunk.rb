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
    module SharedValues
    end

    class TestmunkAction
      def self.run(_params)
        raise "Please pass your Testmunk email address using `ENV['TESTMUNK_EMAIL'] = 'value'`" unless ENV['TESTMUNK_EMAIL']
        raise "Please pass your Testmunk API Key using `ENV['TESTMUNK_API'] = 'value'`" unless ENV['TESTMUNK_API']
        raise "Please pass your Testmunk app name using `ENV['TESTMUNK_APP'] = 'value'`" unless ENV['TESTMUNK_APP']

        ipa_path = ENV['TESTMUNK_IPA'] || ENV[Actions::SharedValues::IPA_OUTPUT_PATH.to_s]
        raise "Please pass a path to your ipa file using `ENV['TESTMUNK_IPA'] = 'value'`" unless ipa_path

        Helper.log.info 'Testmunk: Uploading the .ipa and starting your tests'.green

        response = system("#{"curl -H 'Accept: application/vnd.testmunk.v1+json'" +
            " -F 'file=@#{ipa_path}' -F 'autoStart=true'" +
            " -F 'email=#{ENV['TESTMUNK_EMAIL']}'" +
            " https://#{ENV['TESTMUNK_API']}@api.testmunk.com/apps/#{ENV['TESTMUNK_APP']}/testruns"}")

        if response
          Helper.log.info 'Your tests are being executed right now. Please wait for the mail with results and decide if you want to continue.'.green
        else
          raise 'Something went wrong while uploading your app to Testmunk'.red
        end
      end
    end
  end
end
