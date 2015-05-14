require 'spaceship/version'
require 'fastlane_core'
require 'spaceship/base'
require 'spaceship/client'
require 'spaceship/profile_types'
require 'spaceship/apps'
require 'spaceship/certificates'
require 'spaceship/devices'
require 'spaceship/provisioning_profile'

module Spaceship
  # Use this to just setup the configuration attribute and set it later somewhere else
  class << self
    attr_accessor :config, :client

    def login(username = nil, password = nil)
      username ||= ENV['DELIVER_USER']
      password ||= ENV['DELIVER_PASSWORD']
      @client = Client.login(username, password)
    end

    def apps
      Apps.new(client)
    end

    def certificates
      Certificates.new(client)
    end

    def devices
      Devices.new(client)
    end

    def provisioning_profiles
      ProvisioningProfiles.new(client)
    end
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore

  # FastlaneCore::UpdateChecker.verify_latest_version('spaceship', Spaceship::VERSION)
end
