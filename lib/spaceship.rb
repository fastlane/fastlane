require 'spaceship/version'
require 'fastlane_core'
require 'spaceship/urls'
require 'spaceship/client'
require 'spaceship/profile_types'
require 'spaceship/apps'
require 'spaceship/devices/devices'
require 'spaceship/certificates'
require 'spaceship/provisioning_profiles/provisioning_profiles'

module Spaceship
  # Use this to just setup the configuration attribute and set it later somewhere else
  class << self
    attr_accessor :config
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore

  # FastlaneCore::UpdateChecker.verify_latest_version('spaceship', Spaceship::VERSION)
end
