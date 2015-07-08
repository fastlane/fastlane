require 'cert/version'
require 'cert/dependency_checker'
require 'cert/cert_runner'
require 'cert/signing_request'
require 'cert/keychain_importer'

require 'fastlane_core'
require 'spaceship'

module Cert
  # Use this to just setup the configuration attribute and set it later somewhere else
  class << self
    attr_accessor :config
  end
  
  TMP_FOLDER = "/tmp/cert/"
  FileUtils.mkdir_p TMP_FOLDER

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore

  ENV['FASTLANE_TEAM_ID'] ||= ENV["CERT_TEAM_ID"]

  DependencyChecker.check_dependencies
end
