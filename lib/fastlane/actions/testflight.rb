module Fastlane
  module Actions
    module SharedValues
    end

    class TestflightAction < Action
      def self.run(params)
        values = params.values
        values[:beta] = true # always true for beta actions
        real_options = FastlaneCore::Configuration.create(Actions::DeliverAction.available_options, values)
        return real_options if Helper.is_test?

        Actions::DeliverAction.run(real_options)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload a new build to iTunes Connect. This won't upload app metadata"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :skip_deploy,
                                       env_name: "FL_DELIVER_SKIP_DEPLOY",
                                       description: "Skip the distribution of the app to all beta testers",
                                       default_value: false,
                                       is_string: false)
        ]
      end

      def self.output
        []
      end

      def self.author
        'KrauseFx'
      end

      def self.is_supported?(platform)
        Actions::DeliverAction.is_supported?platform
      end
    end
  end
end