module Frameit
  # Represents one screenshot
  class Screenshot
    attr_accessor :path # path to the screenshot
    attr_accessor :size # size in px array of 2 elements: height and width
    attr_accessor :screen_size # deliver screen size type, is unique per device type, used in device_name
    attr_accessor :color # the color to use for the frame (from Frameit::Color)

    # path: Path to screenshot
    # color: Color to use for the frame
    def initialize(path, color)
      UI.user_error "Couldn't find file at path '#{path}'" unless File.exist? path
      @color = color
      @path = path
      @size = FastImage.size(path)

      @screen_size = ENV["FRAMEIT_FORCE_DEVICE_TYPE"] || Deliver::AppScreenshot.calculate_screen_size(path)
    end

    # Device name for a given screen size. Used to use the correct template
    def device_name
      sizes = Deliver::AppScreenshot::ScreenSize
      case @screen_size
      when sizes::IOS_55
        return 'iPhone-7-Plus'
      when sizes::IOS_47
        return 'iPhone-7'
      when sizes::IOS_40
        return Frameit.config[:use_legacy_iphone5s] ? 'iPhone_5s' : 'iPhone-SE'
      when sizes::IOS_35
        return 'iPhone_4'
      when sizes::IOS_IPAD
        return 'iPad-mini'
      when sizes::IOS_IPAD_PRO
        return 'iPad-Pro'
      when sizes::MAC
        return 'Mac'
      else
        UI.error "Unknown device type for size #{@screen_size} for path '#{path}'"
      end
    end

    # Is the device a 3x device? (e.g. 6 Plus)
    def triple_density?
      (screen_size == Deliver::AppScreenshot::ScreenSize::IOS_55)
    end

    # Super old devices
    def mini?
      (screen_size == Deliver::AppScreenshot::ScreenSize::IOS_35)
    end

    def mac?
      return device_name == 'Mac'
    end

    # The name of the orientation of a screenshot. Used to find the correct template
    def orientation_name
      return Orientation::PORTRAIT if size[0] < size[1]
      return Orientation::LANDSCAPE
    end

    def portrait?
      return (orientation_name == Orientation::PORTRAIT)
    end

    def to_s
      self.path
    end

    # Add the device frame, this will also call the method that adds the background + title
    def frame!
      if self.mac?
        MacEditor.new.frame!(self)
      else
        Editor.new.frame!(self)
      end
    end
  end
end
