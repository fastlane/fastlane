require 'deliver/app_screenshot'
require 'fastimage'

require_relative 'device_types' # color + orientation
require_relative 'module'

module Frameit
  # Represents the frame to be used
  class Frame
    attr_accessor :screenshot
    attr_accessor :color # the color to use for the frame (from Frameit::Color) # TODO remove, see below
    attr_accessor :config 

    # path: Path to screenshot
    # color: Color to use for the frame
    def initialize(screenshot, config, color)
      @screenshot = screenshot
      self.config = config
      @color = color
    end

    # TODO move to Deliver as well similar to `calculate_screen_size`
    def color
      if !Frameit.config[:use_legacy_iphone6s] && @color == Frameit::Color::BLACK
        if @screenshot.screen_size == Deliver::AppScreenshot::ScreenSize::IOS_55 || @screenshot.screen_size == Deliver::AppScreenshot::ScreenSize::IOS_47
          return "Matte Black" # RIP space gray
        elsif @screenshot.screen_size == Deliver::AppScreenshot::ScreenSize::IOS_61
          return "Black"
        end
      end
      return @color
    end


    # The name of the orientation of a screenshot. Used to find the correct template
    def orientation_name
      return Orientation::PORTRAIT if size[0] < size[1]
      return Orientation::LANDSCAPE
    end

    # TODO is this really the _frame_ orientation? If yes, remove it from here as it is not really about the screenshot
    def frame_orientation
      filename = File.basename(self.path, ".*")

      block = Frameit.config[:force_orientation_block]
      unless block.nil?
        orientation = block.call(filename)
        valid = [:landscape_left, :landscape_right, :portrait, nil]
        UI.user_error("orientation_block must return #{valid[0..-2].join(', ')} or nil") unless valid.include?(orientation)
      end
      puts("Forced orientation: #{orientation}") unless orientation.nil?

      return orientation unless orientation.nil?
      return :portrait if self.orientation_name == Orientation::PORTRAIT
      return :landscape_right # Default landscape orientation
    end

    def portrait?
      return (frame_orientation == :portrait)
    end

    def landscape_left?
      return (frame_orientation == :landscape_left)
    end

    def landscape_right?
      return (frame_orientation == :landscape_right)
    end

    def landscape?
      return self.landscape_left? || self.landscape_right
    end

    def to_s
      self.path
    end
  end
end
