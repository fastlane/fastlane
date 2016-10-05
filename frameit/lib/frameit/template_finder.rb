module Frameit
  # Responsible for finding the correct device
  class TemplateFinder
    class FilenameTransform
      def initialize(device_name)
        @device_name = device_name
      end
    end

    # Example: iPhone_5s_Vert_SpaceGray_sRGB
    class Type1Transform < FilenameTransform
      def transform(color, orientation)
        # Note the * on the end to handle the _sRGB part
        "#{@device_name}_#{orientation}_#{color}*"
      end
    end

    # Example: iPad-Pro-Space-Gray-vertical.png
    class Type2Transform < FilenameTransform
      def transform(color, orientation)
        fixed_color = color == 'SpaceGray' ? "Space-Gray" : "Silver"
        fixed_orientation = orientation == 'Horz' ? 'horizontal' : 'vertical'
        "#{@device_name}-#{fixed_color}-#{fixed_orientation}"
      end
    end

    # Example: iPhone-SE-Space-Gray
    # Note that 'vertical' is implied
    class Type3Transform < FilenameTransform
      def transform(color, orientation)
        fixed_color = color == 'SpaceGray' ? "Space-Gray" : "Silver"
        filename = "#{@device_name}-#{fixed_color}"
        if orientation == 'Horz'
          "#{filename}-horizontal"
        else
          filename
        end
      end
    end

    DEVICE_TO_TRANSFORM_TYPE = {
      'iPhone-SE' => Type3Transform.new('iPhone-SE'),
      'iPad-Pro' => Type2Transform.new('iPad-Pro'),
      'iPad-mini' => Type2Transform.new('iPad-mini'),
      'iPhone-7' => Type2Transform.new('iPhone-7'),
      'iPhone-7-Plus' => Type2Transform.new('iPhone-7-Plus')
    }

    # This will detect the screen size and choose the correct template
    def self.get_template(screenshot)
      return nil if screenshot.mac?

      transformer = DEVICE_TO_TRANSFORM_TYPE[screenshot.device_name]

      # The "original" pattern is the type 1 transform
      # so if we don't have something more specific, go for that
      transformer ||= Type1Transform.new(screenshot.device_name)
      filename = transformer.transform(screenshot.color, screenshot.orientation_name)

      templates_path = [ENV['HOME'], FrameConverter::FRAME_PATH].join('/')
      templates = Dir["../**/#{filename}.{png,jpg}"] # local directory
      templates += Dir["#{templates_path}/**/#{filename}.{png,jpg}"] # ~/.frameit folder

      UI.verbose "Looking for #{filename} and found #{templates.count}"

      if templates.count == 0
        if screenshot.screen_size == Deliver::AppScreenshot::ScreenSize::IOS_35
          UI.important "Unfortunately 3.5\" device frames were discontinued. Skipping screen '#{screenshot.path}'"
          UI.error "Looked for: '#{filename}.png'"
        elsif screenshot.device_name == 'iPhone-SE'
          UI.error "By default frameit uses the iPhone SE for screenshots"
          UI.error "Unable to find a frame #{filename}.png"
          UI.error "You can download iPhone-SE templates from '#{FrameConverter::DOWNLOAD_URL}'"
          UI.error "and store them in '#{templates_path}'"
          UI.error "\nIf you'd prefer to use the old iPhone 5s templates, add the option --use_legacy_iphone5s"
        else
          UI.error "Could not find a valid template for screenshot '#{screenshot.path}'"
          UI.error "You can download new templates from '#{FrameConverter::DOWNLOAD_URL}'"
          UI.error "and store them in '#{templates_path}'"
          UI.error "Missing file: '#{filename}.png'"
        end
        return nil
      else
        return templates.first.tr(" ", "\ ")
      end
    end
  end
end
