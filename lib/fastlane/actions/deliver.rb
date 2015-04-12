module Fastlane
  module Actions
    module SharedValues
    end

    class DeliverAction < Action
      def self.run(params)
        require 'deliver'

        FastlaneCore::UpdateChecker.start_looking_for_update('deliver')

        begin
          ENV['DELIVER_SCREENSHOTS_PATH'] = Actions.lane_context[SharedValues::SNAPSHOT_SCREENSHOTS_PATH]

          force = params.include?(:force)
          beta = params.include?(:beta)
          skip_deploy = params.include?(:skip_deploy)

          Dir.chdir(FastlaneFolder.path || Dir.pwd) do
            # This should be executed in the fastlane folder
            Deliver::Deliverer.new(nil,
                                   force: force,
                                   is_beta_ipa: beta,
                                   skip_deploy: skip_deploy)

            Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] = File.expand_path(ENV['DELIVER_IPA_PATH']) # deliver will store it in the environment
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
          ['force', 'Set to true to skip PDF verification'],
          ['beta', 'Upload a new version to TestFlight'],
          ['skip_deploy', 'Skip the submission of the app - it will only be uploaded'],
        ]
      end

      def self.author
        "KrauseFx"
      end
    end
  end
end
