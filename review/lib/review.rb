require 'fastlane_core'
require 'review/runner'
require 'review/options'

module Review
  # Use this to just setup the configuration attribute and set it later somewhere else
  class << self
    attr_accessor :config
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI
  ROOT = Pathname.new(File.expand_path('../..', __FILE__))

  ENV['APP_IDENTIFIER'] ||= ENV["REVIEW_APP_IDENTIFIER"]

  DESCRIPTION = 'Check your app for common App Store review problems before you submit'
end
