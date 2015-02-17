require 'cert/version'
require 'cert/dependency_checker'
require 'cert/developer_center'
require 'cert/cert_runner'
require 'cert/cert_checker'
require 'cert/signing_request'
require 'cert/keychain_importer'

require 'fastlane_core'

module Cert
  TMP_FOLDER = "/tmp/cert/"

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore

  FastlaneCore::UpdateChecker.verify_latest_version('cert', Cert::VERSION)
  DependencyChecker.check_dependencies
end
