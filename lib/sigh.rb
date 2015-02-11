require 'json'
require 'sigh/version'
require 'sigh/helper'
require 'sigh/dependency_checker'
require 'sigh/developer_center'
require 'sigh/update_checker'
require 'sigh/resign'

# Third Party code
require 'colored'
require 'phantomjs/poltergeist'

module Sigh
  TMP_FOLDER = "/tmp/sigh/"

  Sigh::UpdateChecker.verify_latest_version
  DependencyChecker.check_dependencies
end
