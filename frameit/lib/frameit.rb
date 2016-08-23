require 'mini_magick'
require 'frameit/version'
require 'frameit/frame_converter'
require 'frameit/device_types'
require 'frameit/runner'
require 'frameit/screenshot'
require 'frameit/config_parser'
require 'frameit/offsets'
require 'frameit/editor'
require 'frameit/template_finder'
require 'frameit/strings_parser'
require 'frameit/mac_editor'
require 'frameit/dependency_checker'
require 'frameit/options'

require 'fastlane_core'

module Frameit
  class << self
    attr_accessor :config
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI
  ROOT = Pathname.new(File.expand_path('../..', __FILE__))
end

# rubocop:disable all
class ::Hash
  def fastlane_deep_merge(second)
    merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
    self.merge(second, &merger)
  end
end
# rubocop:enable all
