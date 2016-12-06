require 'spaceship/version'
require 'spaceship/base'
require 'spaceship/client'
require 'spaceship/launcher'
require 'spaceship/update_checker'

# Dev Portal
require 'spaceship/portal/portal'
require 'spaceship/portal/spaceship'

# iTunes Connect
require 'spaceship/tunes/tunes'
require 'spaceship/tunes/spaceship'

# To support legacy code
module Spaceship
  ROOT = Pathname.new(File.expand_path('../..', __FILE__))

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

  UpdateChecker.ensure_spaceship_version
end
