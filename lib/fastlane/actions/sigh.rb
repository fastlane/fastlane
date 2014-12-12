module Fastlane
  module Actions
    def self.sigh(params)
      need_gem!'sigh'

      require 'sigh'

      app = AppfileConfig.try_fetch_value(:app_identifier)
      raise "No app_identifier definied in `./fastlane/Appfile`".red unless app

      type = Sigh::DeveloperCenter::APPSTORE
      type = Sigh::DeveloperCenter::ADHOC if params.first == :adhoc
      type = Sigh::DeveloperCenter::DEVELOPMENT if params.first == :development

      path = Sigh::DeveloperCenter.new.run(app, type)
      sh "open '#{path}'"
    end
  end
end