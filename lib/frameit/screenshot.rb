module Frameit
  # Represents one screenshot
  class Screenshot
    attr_accessor :path # path to the screenshot
    attr_accessor :size # size in px array of 2 elements: height and width
    attr_accessor :screen_size # deliver screen size type, is unique per device type, used in device_name
    attr_accessor :color # the color to use for the frame

    # path: Path to screenshot
    # color: Color to use for the frame
    def initialize(path, color)
      raise "Couldn't find file at path '#{path}'".red unless File.exists?path
      @color = color
      @path = path
      @size = FastImage.size(path)
      @screen_size = Deliver::AppScreenshot.calculate_screen_size(path) 
    end

    # Device name for a given screen size. Used to use the correct template
    def device_name
      sizes = Deliver::AppScreenshot::ScreenSize
      case @screen_size
        when sizes::IOS_55
          return 'iPhone_6_Plus'
        when sizes::IOS_47
          return 'iPhone_6'
        when sizes::IOS_40
          return 'iPhone_5s'
        when sizes::IOS_IPAD
          return 'iPad_mini'
      end
    end

    # The name of the orientation of a screenshot. Used to find the correct template
    def orientation_name
      return Orientation::PORTRAIT if size[0] < size[1]
      return Orientation::LANDSCAPE
    end

    def to_s
      self.path
    end

    # Add the device frame
    def frame!
      template_path = TemplateFinder.get_template(self)
      if template_path
        template = MiniMagick::Image.open(template_path)
        image = MiniMagick::Image.open(self.path)

        offset_information = Offsets.image_offset(self)
        raise "Could not find offset_information for '#{self}'" unless (offset_information and offset_information[:width])
        width = offset_information[:width]
        image.resize width

        result = template.composite(image, "png") do |c|
          c.compose "Over"
          c.geometry offset_information[:offset]
        end

        output_path = self.path.gsub('.png', '_framed.png').gsub('.PNG', '_framed.png')
        result.format "png"
        result.write output_path
        Helper.log.info "Added frame: '#{File.expand_path(output_path)}'".green
      end
    end
  end
end