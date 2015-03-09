module Fastlane
  module Actions
    module SharedValues
      SIGH_PROFILE_PATH = :SIGH_PROFILE_PATH
      SIGH_UDID = :SIGH_UDID
    end

    class SighAction
      def self.run(params)
        require 'sigh'
        require 'sigh/options'
        require 'sigh/manager'
        require 'credentials_manager/appfile_config'

        values = params.first
        if params.kind_of?Array
          # Old syntax
          values = {}
          params.each do |val|
            values[val] = true
          end
        end

        Sigh.config = FastlaneCore::Configuration.create(Sigh::Options.available_options, (values || {}))
        
        path = Sigh::Manager.start

        Actions.lane_context[SharedValues::SIGH_PROFILE_PATH] = path # absolute path
        Actions.lane_context[SharedValues::SIGH_UDID] = ENV["SIGH_UDID"] if ENV["SIGH_UDID"] # The UDID of the new profile
      end
    end
  end
end
