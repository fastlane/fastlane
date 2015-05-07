module Frameit
  # Represents one screenshot
  class Screenshot
    attr_accessor :path # path to the screenshot
    attr_accessor :size # size in px array of 2 elements: height and width
    attr_accessor :screen_size # deliver screen size type, is unique per device type, used in device_name
    attr_accessor :color # the color to use for the frame
    attr_accessor :title_height # the height of the title added on top of the screenshot
    attr_accessor :keyword_padding # padding between keyword and title

    # path: Path to screenshot
    # color: Color to use for the frame
    def initialize(path, color)
      raise "Couldn't find file at path '#{path}'".red unless File.exists?path
      @color = color
      @path = path
      @size = FastImage.size(path)
      @screen_size = Deliver::AppScreenshot.calculate_screen_size(path) 
      @title_height = 285
      @keyword_padding = 50
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

    def fetch_config
      return @config if @config

      config_path = File.join(File.expand_path("..", self.path), "Framefile.json")
      config_path = File.join(File.expand_path("../..", self.path), "Framefile.json") unless File.exists?config_path
      file = ConfigParser.new.load(config_path)
      @config = file.fetch_value(self.path)
    end

    # Add the device frame, this will also call the method that adds the background + title
    def frame!
      template_path = TemplateFinder.get_template(self)
      if template_path
        template = MiniMagick::Image.open(template_path)
        image = MiniMagick::Image.open(self.path)

        offset_information = Offsets.image_offset(self)
        raise "Could not find offset_information for '#{self}'" unless (offset_information and offset_information[:width])
        width = offset_information[:width]
        image.resize width

        image = template.composite(image, "png") do |c|
          c.compose "Over"
          c.geometry offset_information[:offset]
        end
        
        if fetch_config['background'] and fetch_config['title'] and fetch_config['keyword']
          image = add_title(image)
        end

        output_path = self.path.gsub('.png', '_framed.png').gsub('.PNG', '_framed.png')
        image.format "png"
        image.write output_path
        Helper.log.info "Added frame: '#{File.expand_path(output_path)}'".green
      end
    end

    def add_title(image)
      # If the user defined a background + title, here we go
      if fetch_config['background']
        background = MiniMagick::Image.open(fetch_config['background'])

        # First off, change the size of `image` to match the background + padding
        frame_width = background.width - fetch_config['padding'] * 2
        image.resize "#{frame_width}x"

        left_space = (background.width / 2.0 - image.width / 2.0).round
        top_space = 20
        top_space += @title_height if fetch_config['title']

        image = background.composite(image, "png") do |c|
          c.compose "Over"
          c.geometry "+#{left_space}+#{top_space}"
        end

        if fetch_config['title']
          title_images = build_title_images(image.width)
          keyword = title_images.first
          title = title_images.last
          sum_width = keyword.width + title.width + @keyword_padding
          top_space = (@title_height / 2.0).round # centered
          
          left_space = (image.width / 2.0 - sum_width / 2.0).round
          image = image.composite(keyword, "png") do |c|
            c.compose "Over"
            c.geometry "+#{left_space}+#{top_space}"
          end

          left_space += keyword.width + @keyword_padding
          image = image.composite(title, "png") do |c|
            c.compose "Over"
            c.geometry "+#{left_space}+#{top_space}"
          end
        end
      end
      image
    end

    # This will assemble one image containing the 2 title parts
    def build_title_images(max_width)
      [:keyword, :title].collect do |key|

        # Create empty background
        title_image = MiniMagick::Image.open("./lib/assets/empty.png")
        title_image.combine_options do |i|
          i.resize "#{max_width}x#{@title_height}!" # `!` says it should ignore the ratio
        end

        # Add the actual title
        font = fetch_config[key.to_s]['font']
        title_image.combine_options do |i|
          i.font font if font
          i.gravity "Center"
          i.pointsize (@title_height / 4.0).round
          i.draw "text 0,0 '#{fetch_config[key.to_s]['text']}'"
          i.fill fetch_config[key.to_s]['color']
        end
        title_image.trim # remove white space

        title_image
      end
    end
  end
end