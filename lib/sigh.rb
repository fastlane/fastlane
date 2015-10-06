require 'sigh/version'
require 'sigh/resign'
require 'sigh/manager'

require 'fastlane_core'

module Sigh
  # Use this to just setup the configuration attribute and set it later somewhere else
  class << self
    attr_accessor :config
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore

  ENV['FASTLANE_TEAM_ID'] ||= ENV["SIGH_TEAM_ID"]
  ENV['DELIVER_USER'] ||= ENV["SIGH_USERNAME"]
end
