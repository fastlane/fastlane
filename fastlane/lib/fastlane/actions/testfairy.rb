module Fastlane
  module Actions
    module SharedValues
      TESTFAIRY_BUILD_URL = :TESTFAIRY_BUILD_URL
    end

    class TestfairyAction < Action
      def self.run(params)
        require 'shenzhen'
        require 'shenzhen/plugins/testfairy'

        UI.success('Starting with ipa upload to TestFairy...')

        client = Shenzhen::Plugins::TestFairy::Client.new(
          params[:api_key]
        )

        return params[:ipa] if Helper.test?

        client_options = params.values

        client_options[:testers_groups] = client_options[:testers_groups].join(',') if client_options.key?(:testers_groups)
        client_options[:metrics] = client_options[:metrics].join(',') if client_options.key?(:metrics)
        client_options[:options] = client_options[:options].join(',') if client_options.key?(:options)
        client_options['auto-update'] = client_options.delete(:auto_update) if client_options.key?(:auto_update)
        client_options['icon-watermark'] = client_options.delete(:icon_watermark) if client_options.key?(:icon_watermark)

        response = client.upload_build(params[:ipa], client_options)
        if parse_response(response)
          UI.success("Build URL: #{Actions.lane_context[SharedValues::TESTFAIRY_BUILD_URL]}")
          UI.success("Build successfully uploaded to TestFairy.")
        else
          UI.user_error!("Error when trying to upload ipa to TestFairy")
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
          UI.error("Error uploading to TestFairy: #{response.body}")

          return false
        end
      end
      private_class_method :parse_response

      def self.description
        'Upload a new build to TestFairy'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_key,
                                       env_name: "FL_TESTFAIRY_API_KEY", # The name of the environment variable
                                       description: "API Key for TestFairy", # a short description of this parameter
                                       verify_block: proc do |value|
                                         UI.user_error!("No API key for TestFairy given, pass using `api_key: 'key'`") unless value.to_s.length > 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :ipa,
                                       env_name: 'TESTFAIRY_IPA_PATH',
                                       description: 'Path to your IPA file. Optional if you use the `gym` or `xcodebuild` action',
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find ipa file at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :comment,
                                       env_name: "FL_TESTFAIRY_COMMENT",
                                       description: "Additional release notes for this upload. This text will be added to email notifications",
                                       default_value: 'No comment provided'), # the default value if the user didn't provide one
          FastlaneCore::ConfigItem.new(key: :testers_groups,
                                       type: Array,
                                       short_option: '-g',
                                       env_name: "FL_TESTFAIRY_TESTERS_GROUPS",
                                       description: "Array of tester groups to be notified",
                                       default_value: []), # the default value is an empty list
          FastlaneCore::ConfigItem.new(key: :symbols_file,
                                       env_name: "FL_TESTFAIRY_SYMBOLS_FILE",
                                       description: "Symbols mapping file",
                                       default_value: Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH],
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find ipa file at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :notify,
                                       env_name: "FL_TESTFAIRY_NOTIFY",
                                       description: "Send email to testers",
                                       default_value: 'on'),
          FastlaneCore::ConfigItem.new(key: :auto_update,
                                       env_name: "FL_TESTFAIRY_AUTO_UPDATE",
                                       description: "Allows easy upgrade of all users to current version",
                                       default_value: 'on'),
          FastlaneCore::ConfigItem.new(key: :icon_watermark,
                                       env_name: "FL_TESTFAIRY_ICON_WATERMARK",
                                       description: "Add a small watermark to app icon",
                                       default_value: 'on'),
          FastlaneCore::ConfigItem.new(key: :metrics,
                                       type: Array,
                                       env_name: "FL_TESTFAIRY_METRICS",
                                       description: "Array of metrics to record (cpu,memory,network,phone-signal,gps,battery,mic,wifi)",
                                       default_value: [ :cpu, :memory, :network, :wifi ]),
          FastlaneCore::ConfigItem.new(key: :options,
                                       type: Array,
                                       env_name: "FL_TESTFAIRY_OPTIONS",
                                       description: "Array of options (shake,video-only-wifi,anonymous)",
                                       default_value: [])
        ]
      end

      def self.output
        [
          ['TESTFAIRY_BUILD_URL', 'URL of the newly uploaded build']
        ]
      end

      def self.authors
        ["taka0125"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
