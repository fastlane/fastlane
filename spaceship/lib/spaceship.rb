require 'spaceship/globals'
require 'spaceship/base'
require 'spaceship/client'
require 'spaceship/launcher'

# Dev Portal
require 'spaceship/portal/portal'
require 'spaceship/portal/spaceship'

# iTunes Connect
require 'spaceship/tunes/tunes'
require 'spaceship/tunes/spaceship'
require 'spaceship/test_flight'

# To support legacy code
module Spaceship
  ROOT = Pathname.new(File.expand_path('../..', __FILE__))

  # Dev Portal
  Certificate = Spaceship::Portal::Certificate
  ProvisioningProfile = Spaceship::Portal::ProvisioningProfile
  Device = Spaceship::Portal::Device
  App = Spaceship::Portal::App
  AppGroup = Spaceship::Portal::AppGroup
  Passbook = Spaceship::Portal::Passbook
  WebsitePush = Spaceship::Portal::WebsitePush
  AppService = Spaceship::Portal::AppService
  Merchant = Spaceship::Portal::Merchant

  # iTunes Connect
  AppVersion = Spaceship::Tunes::AppVersion
  AppSubmission = Spaceship::Tunes::AppSubmission
  Application = Spaceship::Tunes::Application
  Members = Spaceship::Tunes::Members
  Persons = Spaceship::Portal::Persons

  DESCRIPTION = "Ruby library to access the Apple Dev Center and iTunes Connect".freeze
end
