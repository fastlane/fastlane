require 'fastlane_core'

require 'chiizu/version'
require 'chiizu/runner'
require 'chiizu/reports_generator'
require 'chiizu/detect_values'
require 'chiizu/dependency_checker'
require 'chiizu/options'

require 'open3'

module Chiizu
  # Use this to just setup the configuration attribute and set it later somewhere else
  class << self
    attr_accessor :config

    def config=(value)
      @config = value
      DetectValues.set_additional_default_values
    end

    def chiizufile_name
      "Chiizufile"
    end
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI

  Chiizu::DependencyChecker.check_dependencies
end
