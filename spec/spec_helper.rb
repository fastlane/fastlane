require 'spaceship'
require 'spaceship_stubbing'
require 'pry'

require 'coveralls'
Coveralls.wear! unless ENV["FASTLANE_SKIP_UPDATE_CHECK"]

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

ENV["DELIVER_USER"] = "spaceship@krausefx.com"
ENV["DELIVER_PASSWORD"] = "so_secret"
