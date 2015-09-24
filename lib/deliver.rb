require 'json'
require 'deliver/version'
require 'deliver/options'
require 'deliver/commands_generator'
require 'deliver/detect_values'
require 'deliver/runner'
require 'deliver/upload_metadata'

require 'spaceship'
require 'fastlane_core'


# TODO
require 'pry'

module Deliver
	class << self
	end

	Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
end
