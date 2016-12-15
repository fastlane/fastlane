require 'json'
require 'fastlane/version'

# Ruby monkey-patches - should be before almost all else
require 'fastlane_core/core_ext/string'

require 'fastlane_core/env'
require 'fastlane_core/feature/feature'
require 'fastlane_core/features'
require 'fastlane_core/helper'
require 'fastlane_core/xcodebuild_list_output_parser'
require 'fastlane_core/configuration/configuration'
require 'fastlane_core/update_checker/update_checker'
require 'fastlane_core/languages'
require 'fastlane_core/itunes_search_api'
require 'fastlane_core/cert_checker'
require 'fastlane_core/ipa_file_analyser'
require 'fastlane_core/itunes_transporter'
require 'fastlane_core/provisioning_profile'
require 'fastlane_core/pkg_file_analyser'
require 'fastlane_core/pkg_upload_package_builder'
require 'fastlane_core/command_executor'
require 'fastlane_core/ipa_upload_package_builder'
require 'fastlane_core/print_table'
require 'fastlane_core/project'
require 'fastlane_core/device_manager'
require 'fastlane_core/ui/ui'
require 'fastlane_core/tool_collector'
require 'fastlane_core/fastlane_folder'
require 'fastlane_core/keychain_importer'

# Third Party code
require 'colored'
require 'commander'

# after commander import
require 'fastlane_core/ui/fastlane_runner' # monkey patch

module FastlaneCore
  ROOT = Pathname.new(File.expand_path('../..', __FILE__))

  # A directory that's being used to user-wide fastlane configs
  # This directory is also used for the bundled fastlane
  def self.fastlane_user_dir
    path = File.expand_path(File.join("~", ".fastlane"))
    FileUtils.mkdir_p(path) unless File.directory?(path)
    return path
  end
end
