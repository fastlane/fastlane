module Fastlane
  module Actions
    module SharedValues
      SIGH_PROFILE_PATH = :SIGH_PROFILE_PATH
      SIGH_UDID = :SIGH_UDID
    end

    class SighAction
      def self.run(params)
        require 'sigh'
        require 'credentials_manager/appfile_config'

        type = FastlaneCore::DeveloperCenter::APPSTORE
        type = FastlaneCore::DeveloperCenter::ADHOC if params.include? :adhoc
        type = FastlaneCore::DeveloperCenter::DEVELOPMENT if params.include? :development
        force = params.include? :force

        return type if Helper.test?

        app = CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)
        raise 'No app_identifier definied in `./fastlane/Appfile`'.red unless app

        CredentialsManager::PasswordManager.shared_manager(ENV['SIGH_USERNAME']) if ENV['SIGH_USERNAME']
        path = FastlaneCore::DeveloperCenter.new.run(app, type, nil, force)
        output_path = File.expand_path(File.join('.', File.basename(path)))
        FileUtils.mv(path, output_path)
        Helper.log.info "Exported provisioning profile to '#{output_path}'".green
        Actions.sh "open '#{output_path}'" unless params.include? :skip_install

        Actions.lane_context[SharedValues::SIGH_PROFILE_PATH] = output_path # absolute path
        Actions.lane_context[SharedValues::SIGH_UDID] = ENV["SIGH_UDID"] if ENV["SIGH_UDID"] # The UDID of the new profile
      end
    end
  end
end
