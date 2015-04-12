module Fastlane
  module Actions
    module SharedValues
      SIGH_PROFILE_PATH = :SIGH_PROFILE_PATH
      SIGH_UDID = :SIGH_UDID
    end

    class SighAction < Action
      def self.run(params)
        require 'sigh'
        require 'sigh/options'
        require 'sigh/manager'
        require 'credentials_manager/appfile_config'

        values = params.first

        unless values.kind_of?Hash
          # Old syntax
          values = {}
          params.each do |val|
            values[val] = true
          end
        end

        begin
          FastlaneCore::UpdateChecker.start_looking_for_update('sigh')

          Sigh.config = FastlaneCore::Configuration.create(Sigh::Options.available_options, (values || {}))
          
          path = Sigh::Manager.start

          Actions.lane_context[SharedValues::SIGH_PROFILE_PATH] = path # absolute path
          Actions.lane_context[SharedValues::SIGH_UDID] = ENV["SIGH_UDID"] if ENV["SIGH_UDID"] # The UDID of the new profile
        ensure
          FastlaneCore::UpdateChecker.show_update_status('sigh', Sigh::VERSION)
        end
      end

      def self.description
        "This generates and downloads your provisioning profile. sigh will store the generated profile in the current folder."
      end

      def self.available_options
        require 'sigh'
        require 'sigh/options'
        Sigh::Options.available_options
      end
    end
  end
end
