require 'fastlane_core/ui/ui'
require 'fastlane_core/helper'

module Sigh
  # Use this to just setup the configuration attribute and set it later somewhere else
  class << self
    attr_accessor :config

    def profile_pretty_type(profile_type)
      require 'spaceship'

      case profile_type
      when Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_DEVELOPMENT,
        Spaceship::ConnectAPI::Profile::ProfileType::MAC_APP_DEVELOPMENT,
        Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_DEVELOPMENT,
        Spaceship::ConnectAPI::Profile::ProfileType::MAC_CATALYST_APP_DEVELOPMENT
        "Development"
      when Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_STORE,
        Spaceship::ConnectAPI::Profile::ProfileType::MAC_APP_STORE,
        Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_STORE,
        Spaceship::ConnectAPI::Profile::ProfileType::MAC_CATALYST_APP_STORE
        "AppStore"
      when Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_ADHOC,
        Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_ADHOC
        "AdHoc"
      when Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_INHOUSE,
        Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_INHOUSE,
        Spaceship::ConnectAPI::Profile::ProfileType::MAC_APP_INHOUSE,
        Spaceship::ConnectAPI::Profile::ProfileType::MAC_CATALYST_APP_INHOUSE
        "InHouse"
      when Spaceship::ConnectAPI::Profile::ProfileType::MAC_APP_DIRECT,
        Spaceship::ConnectAPI::Profile::ProfileType::MAC_CATALYST_APP_DIRECT
        "Direct"
      end
    end
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI
  ROOT = Pathname.new(File.expand_path('../../..', __FILE__))

  ENV['FASTLANE_TEAM_ID'] ||= ENV["SIGH_TEAM_ID"]
  ENV['DELIVER_USER'] ||= ENV["SIGH_USERNAME"]
end
