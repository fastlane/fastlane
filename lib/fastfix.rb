require 'fastfix/version'
require 'fastfix/options'
require 'fastfix/runner'
require 'fastfix/nuke'
require 'fastfix/utils'
require 'fastfix/table_printer'
require 'fastfix/git_helper'
require 'fastfix/generator'

require 'fastlane_core'
require 'terminal-table'
require 'spaceship'

module Fastfix
  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
end
