require 'mini_magick'
require 'frameit/frame_downloader'
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
