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

    def profile_type_for_config(platform:, in_house:, config:)
      profile_type = nil

      case platform.to_s
      when "ios"
        profile_type = Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_STORE
        profile_type = Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_INHOUSE if in_house
        profile_type = Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_ADHOC if config[:adhoc]
        profile_type = Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_DEVELOPMENT if config[:development]
      when "tvos"
        profile_type = Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_STORE
        profile_type = Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_INHOUSE if in_house
        profile_type = Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_ADHOC if config[:adhoc]
        profile_type = Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_DEVELOPMENT if config[:development]
      when "macos"
        profile_type = Spaceship::ConnectAPI::Profile::ProfileType::MAC_APP_STORE
        profile_type = Spaceship::ConnectAPI::Profile::ProfileType::MAC_APP_INHOUSE if in_house
        profile_type = Spaceship::ConnectAPI::Profile::ProfileType::MAC_APP_DEVELOPMENT if config[:development]
        profile_type = Spaceship::ConnectAPI::Profile::ProfileType::MAC_APP_DIRECT if config[:developer_id]
      when "catalyst"
        profile_type = Spaceship::ConnectAPI::Profile::ProfileType::MAC_CATALYST_APP_STORE
        profile_type = Spaceship::ConnectAPI::Profile::ProfileType::MAC_CATALYST_APP_INHOUSE if in_house
        profile_type = Spaceship::ConnectAPI::Profile::ProfileType::MAC_CATALYST_APP_DEVELOPMENT if config[:development]
        profile_type = Spaceship::ConnectAPI::Profile::ProfileType::MAC_CATALYST_APP_DIRECT if config[:developer_id]
      end

      profile_type
    end

    def profile_type_for_distribution_type(platform:, distribution_type:)
      config = { distribution_type.to_sym => true }
      in_house = distribution_type == "enterprise"

      self.profile_type_for_config(platform: platform, in_house: in_house, config: config)
    end

    def certificate_types_for_profile_and_platform(platform:, profile_type:)
      types = []

      case platform
      when 'ios', 'tvos'
        if profile_type == Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_DEVELOPMENT || profile_type == Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_DEVELOPMENT
          types = [
            Spaceship::ConnectAPI::Certificate::CertificateType::DEVELOPMENT,
            Spaceship::ConnectAPI::Certificate::CertificateType::IOS_DEVELOPMENT
          ]
        elsif profile_type == Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_INHOUSE || profile_type == Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_INHOUSE
          # Enterprise accounts don't have access to Apple Distribution certificates
          types = [
            Spaceship::ConnectAPI::Certificate::CertificateType::IOS_DISTRIBUTION
          ]
        # handles case where the desired certificate type is adhoc but the account is an enterprise account
        # the apple dev portal api has a weird quirk in it where if you query for distribution certificates
        # for enterprise accounts, you get nothing back even if they exist.
        elsif (profile_type == Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_ADHOC || profile_type == Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_ADHOC) && Spaceship::ConnectAPI.client && Spaceship::ConnectAPI.client.in_house?
          # Enterprise accounts don't have access to Apple Distribution certificates
          types = [
            Spaceship::ConnectAPI::Certificate::CertificateType::IOS_DISTRIBUTION
          ]
        else
          types = [
            Spaceship::ConnectAPI::Certificate::CertificateType::DISTRIBUTION,
            Spaceship::ConnectAPI::Certificate::CertificateType::IOS_DISTRIBUTION
          ]
        end

      when 'macos', 'catalyst'
        if profile_type == Spaceship::ConnectAPI::Profile::ProfileType::MAC_APP_DEVELOPMENT || profile_type == Spaceship::ConnectAPI::Profile::ProfileType::MAC_CATALYST_APP_DEVELOPMENT
          types = [
            Spaceship::ConnectAPI::Certificate::CertificateType::DEVELOPMENT,
            Spaceship::ConnectAPI::Certificate::CertificateType::MAC_APP_DEVELOPMENT
          ]
        elsif profile_type == Spaceship::ConnectAPI::Profile::ProfileType::MAC_APP_STORE || profile_type == Spaceship::ConnectAPI::Profile::ProfileType::MAC_CATALYST_APP_STORE
          types = [
            Spaceship::ConnectAPI::Certificate::CertificateType::DISTRIBUTION,
            Spaceship::ConnectAPI::Certificate::CertificateType::MAC_APP_DISTRIBUTION
          ]
        elsif profile_type == Spaceship::ConnectAPI::Profile::ProfileType::MAC_APP_DIRECT || profile_type == Spaceship::ConnectAPI::Profile::ProfileType::MAC_CATALYST_APP_DIRECT
          types = [
            Spaceship::ConnectAPI::Certificate::CertificateType::DEVELOPER_ID_APPLICATION,
            Spaceship::ConnectAPI::Certificate::CertificateType::DEVELOPER_ID_APPLICATION_G2
          ]
        elsif profile_type == Spaceship::ConnectAPI::Profile::ProfileType::MAC_APP_INHOUSE || profile_type == Spaceship::ConnectAPI::Profile::ProfileType::MAC_CATALYST_APP_INHOUSE
          # Enterprise accounts don't have access to Apple Distribution certificates
          types = [
            Spaceship::ConnectAPI::Certificate::CertificateType::MAC_APP_DISTRIBUTION
          ]
        else
          types = [
            Spaceship::ConnectAPI::Certificate::CertificateType::DISTRIBUTION,
            Spaceship::ConnectAPI::Certificate::CertificateType::MAC_APP_DISTRIBUTION
          ]
        end
      end

      types
    end
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI
  ROOT = Pathname.new(File.expand_path('../../..', __FILE__))

  ENV['FASTLANE_TEAM_ID'] ||= ENV["SIGH_TEAM_ID"]
  ENV['DELIVER_USER'] ||= ENV["SIGH_USERNAME"]
end
