require 'cryptex/version'
require 'cryptex/runner'
require 'cryptex/options'

require 'fastlane_core'
require 'spaceship'

module Cryptex
  # Use this to just setup the configuration attribute and set it later somewhere else
  class << self
    attr_accessor :config
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI
end
