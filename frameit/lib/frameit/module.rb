require 'fastlane_core/helper'

require_relative 'config_parser'

module Frameit
  class << self
    attr_accessor :config
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI
  ROOT = Pathname.new(File.expand_path('../../..', __FILE__))

  # Defaults to latest, might be a time stamp if defined in the Framefile.json
  def self.frames_version
    return @frames_version if @frames_version
    @frames_version = "latest"

    config_files = Dir["./**/Framefile.json"]
    if config_files.count > 0
      config = ConfigParser.new.load(config_files.first)
      if config.data["device_frame_version"].to_s.length > 0
        @frames_version = config.data["device_frame_version"]
      end
    end

    UI.success("Using device frames version '#{@frames_version}'")

    return @frames_version
  end
end

# rubocop:disable all
class ::Hash
  def fastlane_deep_merge(second)
    merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
    self.merge(second, &merger)
  end
end
# rubocop:enable all
