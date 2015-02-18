module Fastlane
  module Actions
    module SharedValues
      SIGH_PROFILE_PATH = :SIGH_PROFILE_PATH
    end

    class SighAction
      def self.run(params)
        require 'sigh'
        require 'credentials_manager/appfile_config'

        type = FastlaneCore::DeveloperCenter::APPSTORE
        type = FastlaneCore::DeveloperCenter::ADHOC if params.include? :adhoc
        type = FastlaneCore::DeveloperCenter::DEVELOPMENT if params.include? :development

        return type if Helper.test?

        app = CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)
        raise 'No app_identifier definied in `./fastlane/Appfile`'.red unless app

        path = FastlaneCore::DeveloperCenter.new.run(app, type)
        output_path = File.expand_path(File.join('.', File.basename(path)))
        FileUtils.mv(path, output_path)
        Helper.log.info "Exported provisioning profile to '#{output_path}'".green
        Actions.sh "open '#{output_path}'" unless params.include? :skip_install

        Actions.lane_context[SharedValues::SIGH_PROFILE_PATH] = output_path # absolute URL
      end
    end
  end
end
