require 'deliver/app_screenshot'
require 'fastimage'

require_relative 'device_types' # color + orientation
require_relative 'module'

module Frameit
  # Represents one screenshot
  class Screenshot
    attr_accessor :path # path to the screenshot
    attr_accessor :size # size in px array of 2 elements: height and width
    attr_accessor :screen_size # deliver screen size type, is unique per device type, used in device_name

    # path: Path to screenshot
    def initialize(path)
      UI.user_error!("Couldn't find file at path '#{path}'") unless File.exist?(path)
      @path = path
      @size = FastImage.size(path)

      # 
      @screen_size = ENV["FRAMEIT_FORCE_DEVICE_TYPE"] || Deliver::AppScreenshot.calculate_screen_size(path)
    end

    # Device name for a given screen size. Used to use the correct template
    # TODO move to Deliver as well similar to `calculate_screen_size`
    # TODO also save this as @device_name in initialize instead of using this method all throughout the code
    def device_name
      # rubocop:disable Require/MissingRequireStatement
      sizes = Deliver::AppScreenshot::ScreenSize
      case @screen_size
      when sizes::IOS_65
        return 'iPhone XS Max'
      when sizes::IOS_61
        return 'iPhone XR'
      when sizes::IOS_58
        return Frameit.config[:use_legacy_iphonex] ? 'iPhone X' : 'iPhone XS'
      when sizes::IOS_55
        return Frameit.config[:use_legacy_iphone6s] ? 'iPhone 6s Plus' : 'iPhone 7 Plus'
      when sizes::IOS_47
        return Frameit.config[:use_legacy_iphone6s] ? 'iPhone 6s' : 'iPhone 7'
      when sizes::IOS_40
        return Frameit.config[:use_legacy_iphone5s] ? 'iPhone 5s' : 'iPhone SE'
      when sizes::IOS_35
        return 'iPhone 4'
      when sizes::IOS_IPAD
        return 'iPad Air 2'
      when sizes::IOS_IPAD_PRO
        return 'iPad Pro'
      when sizes::MAC
        return 'MacBook'
      else
        UI.error("Unknown device type for size #{@screen_size} for path '#{path}'")
      end
      # rubocop:enable Require/MissingRequireStatement
    end

    # TODO move to Deliver as well similar to `calculate_screen_size`
    # Is the device a 3x device? (e.g. iPhone 6 Plus, iPhone X)
    # used in wrapper
    def triple_density?
      (screen_size == Deliver::AppScreenshot::ScreenSize::IOS_55 || screen_size == Deliver::AppScreenshot::ScreenSize::IOS_58 || screen_size == Deliver::AppScreenshot::ScreenSize::IOS_65)
    end

    # TODO move to Deliver as well similar to `calculate_screen_size`
    # used in runner
    def mac?
      return device_name == 'MacBook'
    end

    #
    # Screenshot orientation
    #

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
