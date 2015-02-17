require 'cert/version'
require 'cert/dependency_checker'
require 'cert/developer_center'
require 'cert/cert_runner'
require 'cert/cert_checker'
require 'cert/signing_request'
require 'cert/keychain_importer'

module Cert
  TMP_FOLDER = "/tmp/cert/"

  Cert::UpdateChecker.verify_latest_version
  DependencyChecker.check_dependencies
end
