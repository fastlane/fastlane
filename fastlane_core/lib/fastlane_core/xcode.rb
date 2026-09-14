module FastlaneCore
  # Pure-Ruby readers for the files that make up an Xcode project: the `project.pbxproj`,
  # `.xcworkspace`, `.xcscheme`, `.xcconfig` and plist files. They only read, so fastlane
  # can inspect a project without loading the Xcodeproj gem (which is still used for writes).
  module Xcode
  end
end

require_relative 'xcode/error'
require_relative 'xcode/ascii_plist'
require_relative 'xcode/plist'
require_relative 'xcode/xcconfig'
require_relative 'xcode/project'
require_relative 'xcode/workspace'
require_relative 'xcode/scheme'
