require 'json'
require 'pem/version'
require 'pem/helper'
require 'pem/dependency_checker'
require 'pem/developer_center'
require 'pem/update_checker'
require 'pem/cert_manager'
require 'pem/signing_request'

# Third Party code
require 'phantomjs/poltergeist'
require 'colored'

module PEM
  TMP_FOLDER = "/tmp/PEM/"

  PEM::UpdateChecker.verify_latest_version
  DependencyChecker.check_dependencies
end
