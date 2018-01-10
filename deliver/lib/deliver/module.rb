require 'fastlane_core/helper'
require 'fastlane_core/ui/ui'

module Deliver
  class << self
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI

  # Constant that captures the root Pathname for the project. Should be used for building paths to assets or other
  # resources that code needs to locate locally
  ROOT = Pathname.new(File.expand_path('../../..', __FILE__))

  DESCRIPTION = 'Upload screenshots, metadata and your app to the App Store using a single command'
end
