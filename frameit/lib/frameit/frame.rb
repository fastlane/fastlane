require 'deliver/app_screenshot'
require 'fastimage'

require_relative 'device_types' # color + orientation
require_relative 'module'

module Frameit
  # Represents the frame to be used
  class Frame
    attr_accessor :color
    attr_accessor :path
    attr_accessor :offset

    # screenshot: screenshot object
    # cli_color: Color specified via CLI
    # framefile_config: Configuration in Framefile.json for this screenshot
    def initialize(screenshot, cli_color, framefile_config)
      @color = find_color(cli_color, framefile_config)
      @path = load_frame(screenshot, @color)
    end

    def find_color(cli_color, framefile_config)
      # `frame` in Framefile.json
      framefile_override_color = fetch_framefile_config_color(framefile_config)
      return framefile_override_color if framefile_override_color

      # color param in CLI
      return cli_color if cli_color

      # options of action
      # TODO remove these options and introduce a new `color` option
      return Frameit::Color::SILVER if Frameit.config[:white] || Frameit.config[:silver]
      return Frameit::Color::GOLD if Frameit.config[:gold]
      return Frameit::Color::ROSE_GOLD if Frameit.config[:rose_gold]

      # default
      return Frameit::Color::BLACK 
    end

    def fetch_framefile_config_color(framefile_config)
      override_color = framefile_config['frame']
      if override_color == "BLACK"
        return Frameit::Color::BLACK
      elsif override_color == "WHITE"
        return Frameit::Color::SILVER
      elsif override_color == "GOLD"
        return Frameit::Color::GOLD
      elsif override_color == "ROSE_GOLD"
        return Frameit::Color::ROSE_GOLD
      end
      return nil
    end

    def load_frame(screenshot, color)
      override_color = fetch_framefile_config_color(framefile_config)
      frame_path = TemplateFinder.get_template(screenshot, color)
      UI.message("found frame: #{frame_path}") # TODO remove
      return frame_path
    end
  end
end
