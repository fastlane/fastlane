require 'json'
require 'fastlane/version'
require 'fastlane/boolean'

require 'fastlane_core/globals'
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
require 'fastlane_core/swag'
require 'fastlane_core/build_watcher'
require 'fastlane_core/crash_reporter/crash_reporter'
require 'fastlane_core/crash_reporter/crash_report_generator'
require 'fastlane_core/crash_reporter/crash_report_sanitizer'
require 'fastlane_core/ui/errors/fastlane_exception'
require 'fastlane_core/ui/errors/fastlane_error'
require 'fastlane_core/ui/errors/fastlane_crash'
require 'fastlane_core/ui/errors/fastlane_shell_error'
require 'fastlane_core/ui/errors/fastlane_common_error'
require 'fastlane_core/test_parser'
require 'fastlane_core/analytics/action_completion_context'
require 'fastlane_core/analytics/action_launch_context'
require 'fastlane_core/analytics/analytics_event_builder'
require 'fastlane_core/analytics/analytics_ingester_client'
require 'fastlane_core/analytics/analytics_session'

# Third Party code
require 'colored'
require 'commander'

# after commander import
require 'fastlane_core/ui/fastlane_runner' # monkey patch

Boolean = Fastlane::Boolean

module FastlaneCore
  ROOT = Pathname.new(File.expand_path('../..', __FILE__))

  # Session is used to report usage metrics.
  # If you opt out, we will not send anything.
  # You can confirm this by observing how we use the environment variable: FASTLANE_OPT_OUT_USAGE
  # Specifically, in AnalyticsSession.finalize_session
  # Learn more at https://github.com/fastlane/fastlane#metrics
  def self.session
    @session ||= AnalyticsSession.new
  end

  def self.reset_session
    @session = nil
  end

  # A directory that's being used to user-wide fastlane configs
  # This directory is also used for the bundled fastlane
  # Since we don't want to access FastlaneCore from spaceship
  # this method is duplicated in spaceship/client.rb
  def self.fastlane_user_dir
    path = File.expand_path(File.join("~", ".fastlane"))
    FileUtils.mkdir_p(path) unless File.directory?(path)
    return path
  end
end
