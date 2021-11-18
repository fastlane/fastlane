require 'fastlane_core/helper'
require 'fastlane/boolean'

module Trainer
  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI
  Boolean = Fastlane::Boolean
  ROOT = Pathname.new(File.expand_path('../../..', __FILE__))
  DESCRIPTION = "Convert xcodebuild plist and xcresult files to JUnit reports"
end
