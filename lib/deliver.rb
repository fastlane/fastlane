require 'json'
require 'deliver/version'
require 'deliver/app'
require 'deliver/app_metadata'
require 'deliver/metadata_item'
require 'deliver/app_screenshot'
require 'deliver/itunes_connect/itunes_connect'
require 'deliver/itunes_transporter'
require 'deliver/deliverfile/deliverfile'
require 'deliver/deliverfile/deliverfile_creator'
require 'deliver/deliverer'
require 'deliver/ipa_uploader'
require 'deliver/html_generator'
require 'deliver/deliver_process'
require 'deliver/dependency_checker'
require 'deliver/ipa_file_analyser'
require 'deliver/testflight'
require 'deliver/commands_generator'

require 'fastlane_core'

module Deliver
  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
end
