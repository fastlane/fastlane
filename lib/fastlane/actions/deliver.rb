module Fastlane
  module Actions
    module SharedValues
    end

    class DeliverAction < Action
      def self.run(config)
        require 'deliver'

        FastlaneCore::UpdateChecker.start_looking_for_update('deliver') unless Helper.is_test?

        begin
          ENV['DELIVER_SCREENSHOTS_PATH'] = Actions.lane_context[SharedValues::SNAPSHOT_SCREENSHOTS_PATH] # use snapshot's screenshots if there
          ENV['DELIVER_SKIP_BINARY'] = "1" if config[:metadata_only]
          ENV['DELIVER_VERSION'] = Actions.lane_context[SharedValues::VERSION_NUMBER].to_s

          Dir.chdir(config[:deliver_file_path] || FastlaneFolder.path || Dir.pwd) do
            # This should be executed in the fastlane folder
            return if Helper.is_test?

            Deliver::Deliverer.new(nil,
                                   force: config[:force],
                                   is_beta_ipa: config[:beta],
                                   skip_deploy: config[:skip_deploy])

            if ENV['DELIVER_IPA_PATH'] # since IPA upload is optional
              Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] = File.expand_path(ENV['DELIVER_IPA_PATH']) # deliver will store it in the environment
            end

            # The user might used a different account for deliver
            CredentialsManager::PasswordManager.logout
          end
        ensure
          FastlaneCore::UpdateChecker.show_update_status('deliver', Deliver::VERSION)
        end
      end

      def self.description
        "Uses deliver to upload new app metadata and builds to iTunes Connect"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :force,
                                       env_name: "FL_DELIVER_FORCE",
                                       description: "Set to true to skip PDF verification",
                                       optional: true,
                                       default_value: false,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :beta,
                                       env_name: "FL_DELIVER_BETA",
                                       description: "Upload a new version to TestFlight - this will skip metadata upload",
                                       optional: true,
                                       default_value: false,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :skip_deploy,
                                       env_name: "FL_DELIVER_SKIP_DEPLOY",
                                       description: "Skip the submission of the app - it will only be uploaded",
                                       optional: true,
                                       default_value: false,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :metadata_only,
                                       env_name: "DELIVER_SKIP_BINARY",
                                       description: "Skip the binary upload and upload app metadata only",
                                       optional: true,
                                       default_value: false,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :deliver_file_path,
                                       env_name: "FL_DELIVER_CONFIG_PATH",
                                       description: "Specify a path to the directory containing the Deliverfile",
                                       default_value: FastlaneFolder.path || Dir.pwd, # defaults to fastlane folder
                                       verify_block: Proc.new do |value|
                                        raise "Couldn't find folder '#{value}'. Make sure to pass the path to the directory not the file!".red unless File.directory?(value)
                                       end)
        ]
      end

      def self.author
        "KrauseFx"
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?platform
      end
    end
  end
end
