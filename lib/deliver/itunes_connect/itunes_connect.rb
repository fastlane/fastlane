require 'fastlane_core/itunes_connect/itunes_connect'

# Import all the actions
require 'deliver/itunes_connect/itunes_connect_submission'
require 'deliver/itunes_connect/itunes_connect_reader'
require 'deliver/itunes_connect/itunes_connect_new_version'
require 'deliver/itunes_connect/itunes_connect_app_icon'
require 'deliver/itunes_connect/itunes_connect_app_rating'
require 'deliver/itunes_connect/itunes_connect_additional'

module Deliver
  ItunesConnect = FastlaneCore::ItunesConnect
end