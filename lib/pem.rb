require 'pem/version'
require 'pem/dependency_checker'
require 'pem/developer_center'
require 'pem/cert_manager'
require 'pem/signing_request'

require 'fastlane_core'

module PEM
  TMP_FOLDER = "/tmp/PEM/"

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore

  FastlaneCore::UpdateChecker.verify_latest_version('pem', PEM::VERSION)
  DependencyChecker.check_dependencies
end
