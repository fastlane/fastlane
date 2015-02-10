require 'json'
require 'cert/version'
require 'cert/helper'
require 'cert/dependency_checker'
require 'cert/developer_center'
require 'cert/update_checker'
require 'cert/cert_runner'
require 'cert/signing_request'

# Third Party code
require 'phantomjs/poltergeist'
require 'colored'

module Cert
  TMP_FOLDER = "/tmp/cert/"

  Cert::UpdateChecker.verify_latest_version
  DependencyChecker.check_dependencies
end
