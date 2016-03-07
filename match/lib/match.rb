require 'match/version'
require 'match/options'
require 'match/runner'
require 'match/nuke'
require 'match/utils'
require 'match/table_printer'
require 'match/git_helper'
require 'match/generator'
require 'match/setup'
require 'match/encrypt'
require 'match/spaceship_ensure'
require 'match/change_password'

require 'fastlane_core'
require 'terminal-table'
require 'spaceship'

module Match
  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI

  def self.environments
    envs = %w(appstore adhoc development)
    envs << "enterprise" if self.enterprise?
    return envs
  end

  def self.enterprise?
    ENV["MATCH_FORCE_ENTERPRISE"]
  end
end
