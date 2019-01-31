require 'mini_magick'

require_relative 'module'
require_relative 'offsets'
require_relative 'device_types'  # color + orientation

module Frameit
  class Framer
    attr_accessor :framefile_config # Framefile
    
    # TODO Clean up @ vs. self.

    def frame!(screenshot, frame, framefile_config)
      self.framefile_config = framefile_config
    
      result = put_into_frame(screenshot, frame) # put it in the frame

      store_result(result) # write to file system
    end

    private

    def put_into_frame(screenshot, frame)

      frame_image = MiniMagick::Image.open(frame.path)
      screenshot_image = MiniMagick::Image.open(screenshot.path)

      # Rotate screenshot to portrait so frame offset information can be used
      rotation = screenshot.rotation_for_device_orientation
      frame_image.rotate(-rotation)

      # Debug Mode: Add filename to frame
      if Frameit.config[:debug_mode]
        filename = File.basename(frame.path, ".*")
        filename.sub!('Apple', '') # remove 'Apple'

        width = screenshot.size[0]
        font_size = width / 20 # magic number that works well

        offset_top = offset['offset'].split("+")[2].to_f
        annotate_offset = "+0+#{offset_top}" # magic number that works semi well

        frame_image.combine_options do |c|
          c.gravity('North')
          c.undercolor('#00000080')
          c.fill('white')
          c.pointsize(font_size)
          c.annotate(annotate_offset.to_s, filename.to_s)
        end
      end

      image = frame_image.composite(image, "png") do |c|
        c.compose("DstOver")
        c.geometry(offset['offset'])
      end

      # Revert the rotation from above
      image.rotate(rotation)
    end

    

    # TODO duplicated between editor and wrapper
    # TODO Offset = Frame information
    def offset
      return @offset_information if @offset_information

      @offset_information = self.framefile_config['offset'] || Offsets.image_offset(screenshot).dup

      if @offset_information && (@offset_information['offset'] || @offset_information['offset'])
        return @offset_information
      end
      UI.user_error!("Could not find offset_information for '#{screenshot}'")
    end

    def store_result
      output_path = screenshot.path.gsub('.png', '_framed.png').gsub('.PNG', '_framed.png')
      @image.format("png")
      @image.write(output_path)
      Helper.hide_loading_indicator
      UI.success("Added frame: '#{File.expand_path(output_path)}'")
      return output_path
    end

  end
end
