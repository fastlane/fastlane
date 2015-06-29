module Fastlane
  module Actions
    module SharedValues
    end

    class AppstoreAction < Action
      def self.run(params)
        values = params.values
        values[:beta] = false # always false for App Store
        real_options = FastlaneCore::Configuration.create(Actions::DeliverAction.available_options, values)
        return real_options if Helper.is_test?

        Actions::DeliverAction.run(real_options)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload new metadata to iTunes Connect and optionally a new binary"
      end

      def self.available_options
        options = DeliverAction.available_options
        options.delete_if { |i| i.key == :beta } # we don't want to have beta values here
        return options
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