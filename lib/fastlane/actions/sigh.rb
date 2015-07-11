module Fastlane
  module Actions
    module SharedValues
      SIGH_PROFILE_PATH = :SIGH_PROFILE_PATH
      SIGH_UDID = :SIGH_UDID
    end

    class SighAction < Action
      def self.run(values)
        require 'sigh'
        require 'sigh/options'
        require 'sigh/manager'
        require 'credentials_manager/appfile_config'

        begin
          FastlaneCore::UpdateChecker.start_looking_for_update('sigh') unless Helper.is_test?

          Sigh.config = values # we alread have the finished config
          
          path = Sigh::Manager.start

          Actions.lane_context[SharedValues::SIGH_PROFILE_PATH] = path # absolute path
          Actions.lane_context[SharedValues::SIGH_UDID] = ENV["SIGH_UDID"] if ENV["SIGH_UDID"] # The UDID of the new profile

          return ENV["SIGH_UDID"] # return the UDID of the new profile
        ensure
          FastlaneCore::UpdateChecker.show_update_status('sigh', Sigh::VERSION)
        end
      end

      def self.description
        "Generates a provisioning profile. Stores the profile in the current folder"
      end

      def self.author
        "KrauseFx"
      end

      def self.available_options
        require 'sigh'
        require 'sigh/options'
        Sigh::Options.available_options
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
