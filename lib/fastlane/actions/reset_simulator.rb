module Fastlane
  module Actions
    module SharedValues
      RESET_SIMULATOR_CUSTOM_VALUE = :RESET_SIMULATOR_CUSTOM_VALUE
    end

    class ResetSimulatorAction < Action
      def self.run(params)
        require 'json'

        unless min_xcode7?
          Helper.log.error "Xcode version 7 or higher is required!".red
          return
        end

        json = JSON.parse(Actions.sh_no_action("xcrun simctl list --json devices", log: false))
        json["devices"].each do |os, devices|
          devices.each do |device|
            next unless
              params[:device] == "all" ||
              params[:device] == device["udid"] ||
              params[:device] == device["name"] && (params[:os].nil? || params[:os] == os)

            Actions.sh("xcrun simctl shutdown #{device['udid']}") if device["state"] == "Booted"
            Actions.sh("xcrun simctl erase #{device['udid']}")

            # Unless resetting all simulators, it's time to stop
            return unless params[:device] == "all" # rubocop:disable Lint/NonLocalExitFromIterator
          end
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Reset (shutdown + erase) iOS simulator"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :device,
                                       env_name: "FL_RESET_SIMULATOR_DEVICE",
                                       description: "Simulator name, UDID or \"all\""),
          FastlaneCore::ConfigItem.new(key: :os,
                                       env_name: "FL_RESET_SIMULATOR_OS",
                                       description: "Specify simulator OS, e.g. \"iOS 9.0\", \"watchOS 2.1\", etc",
                                       optional: true)
        ]
      end

      def self.output
      end

      def self.authors
        ["mgrebenets"]
      end

      def self.is_supported?(platform)
        [:ios].include?(platform)
      end

      def self.min_xcode7?
        Helper.xcode_version.split(".").first.to_i >= 7
      end
      private_class_method :min_xcode7?

    end
  end
end
