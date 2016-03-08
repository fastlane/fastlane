require 'spaceship/version'
require 'spaceship/base'
require 'spaceship/client'
require 'spaceship/launcher'
require 'fastlane_core'

# Dev Portal
require 'spaceship/portal/portal'
require 'spaceship/portal/spaceship'

# iTunes Connect
require 'spaceship/tunes/tunes'
require 'spaceship/tunes/spaceship'

# To support legacy code
module Spaceship
  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore

  # Dev Portal
  Certificate = Spaceship::Portal::Certificate
  ProvisioningProfile = Spaceship::Portal::ProvisioningProfile
  Device = Spaceship::Portal::Device
  App = Spaceship::Portal::App
  AppGroup = Spaceship::Portal::AppGroup
  AppService = Spaceship::Portal::AppService

  # iTunes Connect
  AppVersion = Spaceship::Tunes::AppVersion
  AppSubmission = Spaceship::Tunes::AppSubmission
  Application = Spaceship::Tunes::Application
end
