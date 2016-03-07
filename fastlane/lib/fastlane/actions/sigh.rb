module Fastlane
  module Actions
    module SharedValues
      SIGH_PROFILE_PATH = :SIGH_PROFILE_PATH
      SIGH_PROFILE_PATHS = :SIGH_PROFILE_PATHS
      SIGH_UDID = :SIGH_UDID
      SIGH_PROFILE_TYPE = :SIGH_PROFILE_TYPE
    end

    class SighAction < Action
      def self.run(values)
        require 'sigh'
        require 'credentials_manager/appfile_config'

        begin
          FastlaneCore::UpdateChecker.start_looking_for_update('sigh') unless Helper.is_test?

          Sigh.config = values # we already have the finished config

          path = Sigh::Manager.start

          Actions.lane_context[SharedValues::SIGH_PROFILE_PATH] = path # absolute path
          Actions.lane_context[SharedValues::SIGH_PROFILE_PATHS] ||= []
          Actions.lane_context[SharedValues::SIGH_PROFILE_PATHS] << path
          Actions.lane_context[SharedValues::SIGH_UDID] = ENV["SIGH_UDID"] if ENV["SIGH_UDID"] # The UDID of the new profile

          set_profile_type(values, ENV["SIGH_PROFILE_ENTERPRISE"])

          return ENV["SIGH_UDID"] # return the UDID of the new profile
        ensure
          FastlaneCore::UpdateChecker.show_update_status('sigh', Sigh::VERSION)
        end
      end

      def self.set_profile_type(values, enterprise)
        profile_type = "app-store"
        profile_type = "ad-hoc" if values[:adhoc]
        profile_type = "development" if values[:development]
        profile_type = "enterprise" if enterprise

        Helper.log.info "Setting Provisioning Profile type to '#{profile_type}'"

        Actions.lane_context[SharedValues::SIGH_PROFILE_TYPE] = profile_type
      end

      def self.description
        "Generates a provisioning profile. Stores the profile in the current folder"
      end

      def self.author
        "KrauseFx"
      end

      def self.return_value
        "The UDID of the profile sigh just fetched/generated"
      end

      def self.available_options
        require 'sigh'
        Sigh::Options.available_options
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
