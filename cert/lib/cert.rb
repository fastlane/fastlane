require 'cert/version'
require 'cert/runner'
require 'cert/keychain_importer'
require 'cert/options'

require 'fastlane_core'
require 'spaceship'

module Cert
  # Use this to just setup the configuration attribute and set it later somewhere else
  class << self
    attr_accessor :config
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI

  ENV['FASTLANE_TEAM_ID'] ||= ENV["CERT_TEAM_ID"]
end
