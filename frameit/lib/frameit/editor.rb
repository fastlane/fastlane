require 'mini_magick'

require_relative 'template_finder'
require_relative 'module'
require_relative 'offsets'
require_relative 'config_parser'
require_relative 'device_types'

module Frameit
  class Editor
    attr_accessor :screenshot # reference to the screenshot object to fetch the path, title, etc.
    attr_accessor :debug_mode
    attr_accessor :frame_path
    attr_accessor :frame # the frame of the device
    attr_accessor :image # the current image used for editing
    attr_accessor :config # Framefile

    def initialize(screenshot, debug_mode = false)
      @screenshot = screenshot
      self.debug_mode = debug_mode
    end
    
    def frame!(screenshot, config)
      self.screenshot = screenshot
      self.config = config
      
      prepare_image

      @frame_path = load_frame
      if @frame_path # Mac doesn't need a frame
        self.frame = MiniMagick::Image.open(@frame_path)
        # Rotate the frame according to the device orientation
        self.frame.rotate(self.rotation_for_device_orientation)
      elsif self.class == Editor
        # Couldn't find device frame (probably an iPhone 4, for which there are no images available any more)
        # Message is already shown elsewhere
        return
      end

      if is_complex_framing_mode?
        @image = complex_framing
      else
        # easy mode from 1.0 - no title or background
        put_into_frame # put it in the frame
      end
      # put_into_frame # put it in the frame

      store_result # write to file system
    end

    def rotation_for_device_orientation
      return 90 if self.screenshot.landscape_right?
      return -90 if self.screenshot.landscape_left?
      return 0
    end

    def should_skip?
      return is_complex_framing_mode? && !fetch_text(:title)
    end

    private

    def prepare_image
      @image = MiniMagick::Image.open(screenshot.path)
    end

    def load_frame
      color = fetch_frame_color
      if color
        screenshot.color = color
      end
      TemplateFinder.get_template(screenshot)
    end

    def store_result
      output_path = screenshot.path.gsub('.png', '_framed.png').gsub('.PNG', '_framed.png')
      image.format("png")
      image.write(output_path)
      Helper.hide_loading_indicator
      UI.success("Added frame: '#{File.expand_path(output_path)}'")
    end

    def put_into_frame
      # We have to rotate the screenshot, since the offset information is for portrait
      # only. Instead of doing the calculations ourselves, it's much easier to let
      # imagemagick do the hard lifting for landscape screenshots
      rotation = self.rotation_for_device_orientation
      frame.rotate(-rotation)
      @image.rotate(-rotation)

      # Debug Mode: Add filename to frame
      if self.debug_mode
        filename = File.basename(@frame_path, ".*")
        filename.sub!('Apple', '') # remove 'Apple'

        width = screenshot.size[0]
        font_size = width / 20 # magic number that works well

        offset_top = offset['offset'].split("+")[2].to_f
        annotate_offset = "+0+#{offset_top}" # magic number that works semi well

        frame.combine_options do |c|
          c.gravity('North')
          c.undercolor('#00000080')
          c.fill('white')
          c.pointsize(font_size)
          c.annotate(annotate_offset.to_s, filename.to_s)
        end
      end

      @image = frame.composite(image, "png") do |c|
        c.compose("DstOver")
        c.geometry(offset['offset'])
      end

      # Revert the rotation from above
      frame.rotate(rotation)
      @image.rotate(rotation)
    end

    # TODO duplicated between editor and wrapper
    def offset
      return @offset_information if @offset_information

      @offset_information = self.config['offset'] || Offsets.image_offset(screenshot).dup

      if @offset_information && (@offset_information['offset'] || @offset_information['offset'])
        return @offset_information
      end
      UI.user_error!("Could not find offset_information for '#{screenshot}'")
    end

    # Do we add a background and title as well?
    def is_complex_framing_mode?
      return (fetch_config['background'] and (fetch_config['title'] or fetch_config['keyword']))
    end

    def fetch_frame_color
      color = self.config['frame']
      if color == "BLACK"
        return Frameit::Color::BLACK
      elsif color == "WHITE"
        return Frameit::Color::SILVER
      elsif color == "GOLD"
        return Frameit::Color::GOLD
      elsif color == "ROSE_GOLD"
        return Frameit::Color::ROSE_GOLD
      end

      return nil
    end

  end
end
