module Spaceship
  # Requiring pathname is required here if not using bundler and requiring spaceship directly
  # https://github.com/fastlane/fastlane/issues/14661
  require 'pathname'

  ROOT = Pathname.new(File.expand_path('../../..', __FILE__))
  DESCRIPTION = "Ruby library to access the Apple Dev Center and App Store Connect".freeze
end
