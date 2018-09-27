#
# Stuff that we always want to be available and so load _right now_
#

# globals
require_relative 'fastlane_core/globals'

# Ruby monkey-patches - should be before almost all else
require_relative 'fastlane_core/core_ext/string'
require_relative 'fastlane_core/core_ext/shellwords'

# Core functionality
require_relative 'fastlane_core/update_checker/update_checker'


# Third Party code
require 'colored'
require 'commander'

# after commander import
require_relative 'fastlane_core/ui/fastlane_runner' # monkey patch

require_relative 'fastlane_core/module'
