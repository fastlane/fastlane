#
# Stuff that we always want to be available and so load _right now_
#

# globals
require_relative 'fastlane_core/globals'

# Ruby monkey-patches - should be before almost all else
require_relative 'fastlane_core/core_ext/string'
require_relative 'fastlane_core/core_ext/shellwords'

# Helpers
require_relative 'fastlane_core/env'
require_relative 'fastlane_core/helper'
require_relative 'fastlane_core/tag_version'

# Feature "flags" (?)
require_relative 'fastlane_core/feature/feature'
require_relative 'fastlane_core/features'

# Core functionality
require_relative 'fastlane_core/fastlane_folder'
require_relative 'fastlane_core/configuration/configuration'
require_relative 'fastlane_core/command_executor'
require_relative 'fastlane_core/ui/ui'
require_relative 'fastlane_core/ui/errors'
require_relative 'fastlane_core/print_table'
require_relative 'fastlane_core/update_checker/update_checker'
require_relative 'fastlane_core/tool_collector'
require_relative 'fastlane_core/analytics/action_completion_context'
require_relative 'fastlane_core/analytics/action_launch_context'
require_relative 'fastlane_core/analytics/analytics_event_builder'
require_relative 'fastlane_core/analytics/analytics_ingester_client'
require_relative 'fastlane_core/analytics/analytics_session'
require_relative 'fastlane_core/fastlane_pty'
require_relative 'fastlane_core/swag'

# Third Party code
require 'colored'
require 'commander'

# after commander import
require_relative 'fastlane_core/ui/fastlane_runner' # monkey patch

require_relative 'fastlane_core/module'
