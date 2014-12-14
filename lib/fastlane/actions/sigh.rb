module Fastlane
  module Actions
    def self.sigh(params)
      execute_action("sigh") do
        require 'sigh'
        require 'credentials_manager/appfile_config'

        app = CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)
        raise "No app_identifier definied in `./fastlane/Appfile`".red unless app

        type = Sigh::DeveloperCenter::APPSTORE
        type = Sigh::DeveloperCenter::ADHOC if params.first == :adhoc
        type = Sigh::DeveloperCenter::DEVELOPMENT if params.first == :development
        
        path = Sigh::DeveloperCenter.new.run(app, type)
        output_path = File.join('.', File.basename(path))
        FileUtils.mv(path, output_path)
        Helper.log.info "Exported provisioning profile to '#{File.expand_path(output_path)}'".green
        sh_no_action "open '#{output_path}'"
      end
    end
  end
end