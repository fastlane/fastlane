require 'json'
require 'deliver/options'
require 'deliver/commands_generator'
require 'deliver/detect_values'
require 'deliver/runner'
require 'deliver/upload_metadata'
require 'deliver/upload_screenshots'
require 'deliver/upload_price_tier'
require 'deliver/upload_assets'
require 'deliver/submit_for_review'
require 'deliver/app_screenshot'
require 'deliver/html_generator'
require 'deliver/generate_summary'
require 'deliver/loader'

require 'spaceship'
require 'fastlane_core'

module Deliver
  class << self
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI

  # Constant that captures the root Pathname for the project. Should be used for building paths to assets or other
  # resources that code needs to locate locally
  ROOT = Pathname.new(File.expand_path('../..', __FILE__))

  DESCRIPTION = 'Upload screenshots, metadata and your app to the App Store using a single command'
end
