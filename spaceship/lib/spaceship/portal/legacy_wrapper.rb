require_relative 'certificate'
require_relative 'provisioning_profile'
require_relative 'device'
require_relative 'app'
require_relative 'app_group'
require_relative 'passbook'
require_relative 'website_push'
require_relative 'app_service'
require_relative 'merchant'

module Spaceship
  Certificate = Spaceship::Portal::Certificate
  ProvisioningProfile = Spaceship::Portal::ProvisioningProfile
  Device = Spaceship::Portal::Device
  App = Spaceship::Portal::App
  AppGroup = Spaceship::Portal::AppGroup
  Passbook = Spaceship::Portal::Passbook
  WebsitePush = Spaceship::Portal::WebsitePush
  AppService = Spaceship::Portal::AppService
  Merchant = Spaceship::Portal::Merchant
end
