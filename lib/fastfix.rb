require 'fastfix/version'
require 'fastfix/options'
require 'fastfix/runner'
require 'fastfix/utils'
require 'fastfix/table_printer'
require 'fastfix/git_helper'
require 'fastfix/generator'

require 'fastlane_core'

module Fastfix
  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
end
