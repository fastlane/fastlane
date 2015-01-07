module Fastlane
  module Actions
    module SharedValues
      SIGH_PROFILE_PATH = :SIGH_PROFILE_PATH
    end

    class SighAction
      def self.run(params)
        require 'sigh'
        require 'credentials_manager/appfile_config'

        type = Sigh::DeveloperCenter::APPSTORE
        type = Sigh::DeveloperCenter::ADHOC if params.first == :adhoc
        type = Sigh::DeveloperCenter::DEVELOPMENT if params.first == :development
        
        return type if Helper.is_test?

        app = CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)
        raise "No app_identifier definied in `./fastlane/Appfile`".red unless app

        path = Sigh::DeveloperCenter.new.run(app, type)
        output_path = File.expand_path(File.join('.', File.basename(path)))
        FileUtils.mv(path, output_path)
        Helper.log.info "Exported provisioning profile to '#{output_path}'".green
        Actions.sh "open '#{output_path}'"

        Actions.lane_context[SharedValues::SIGH_PROFILE_PATH] = output_path # absolute URL
      end
    end
  end
end