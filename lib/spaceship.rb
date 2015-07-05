require 'spaceship/version'
require 'spaceship/base'
require 'spaceship/client'
require 'spaceship/launcher'

# Dev Portal
require 'spaceship/portal/portal'
require 'spaceship/portal/spaceship'

# iTunes Connect
require 'spaceship/tunes/tunes'
require 'spaceship/tunes/spaceship'
require 'spaceship/tunes/external_tester'

# To support legacy code
module Spaceship
  # Dev Portal
  Certificate = Spaceship::Portal::Certificate
  ProvisioningProfile = Spaceship::Portal::ProvisioningProfile
  Device = Spaceship::Portal::Device
  App = Spaceship::Portal::App

  # iTunes Connect
  AppVersion = Spaceship::Tunes::AppVersion
  Application = Spaceship::Tunes::Application
end

