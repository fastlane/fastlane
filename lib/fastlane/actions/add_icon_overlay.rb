module Fastlane
  module Actions
    class AddIconOverlayAction < Action
      def self.run(params)
        Helper.log.info "Image to overlay on icons: #{params[:overlay_image_path]}" if params[:overlay_type] == 'image'
        require 'mini_magick'

        overlay_type = params[:overlay_type]
        appiconset = params[:appiconset_path]

        if overlay_type == 'image'
          self.addImageOverlay(appiconset, params)
        elsif overlay_type == 'banner'
          self.add_banner_overlay(appiconset, params)
        else
          self.add_text_overlay(appiconset, params)
        end
      end

      def self.add_text_overlay(appiconset, params)
        Dir.glob(File.join(appiconset, '*.png')) do |icon|
          img = MiniMagick::Image.new(icon)
          MiniMagick::Tool::Convert.new do |c|
            height = img[:height]*params[:text_overlay_height].to_f
            c.background(params[:text_background_color])
            c.fill(params[:text_foreground_color])
            c.gravity('center')
            c.size("#{img[:width]}x#{height}")
            c.font(params[:text_overlay_font])
            c << "caption:#{params[:text_overlay]}"
            c << icon
            c.swap.+
            c.gravity(params[:text_overlay_position])
            c.composite(icon)
          end
        end
      end

      def self.add_banner_overlay(appiconset, params)
        Dir.glob(File.join(appiconset, '*.png')) do |icon|
          original_icon = MiniMagick::Image.new(icon)
          width = original_icon.width
          height = original_icon.height
          rect_height = height * params[:text_overlay_height].to_f
          rect_width = width * 1.6
          x = width * 0.65 # correct positioning for topright banner
          y = -0.7 * rect_height # correct positioning for topright banner
          text_size = width / 8
          padding = text_size / 2

          result = original_icon.combine_options do |c|
            c.fill(params[:text_background_color])
            c.draw "push graphic-context translate #{x}, #{y} rotate 45 rectangle #{0}, #{0}, #{0 + rect_width}, #{0 + rect_height} pop graphic-context"
          end

          result = result.combine_options do |c|
            c.fill(params[:text_foreground_color]) # set the text fill colour
            c.gravity 'Northeast' # anchor the text to the top right
            c.font(params[:text_overlay_font])
            c.draw "rotate 45 text #{text_size + padding},#{text_size + padding} '#{params[:text_overlay]}'" # draw text
            c.pointsize "#{text_size}" # set font size
          end

          result.write icon
        end
      end

      def self.addImageOverlay(appiconset, params)
        overlay_image = MiniMagick::Image.new(params[:overlay_image_path])

        Dir.glob(File.join(appiconset, '*.png')) do |icon|
          original_icon = MiniMagick::Image.new(icon)

          result = original_icon.composite(overlay_image) do |c|
            c.compose "Over"
            c.resize "#{original_icon.width}x#{original_icon.height}"
            c.quality 100
          end
          result.write icon
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Overlays an image or text over all icons."
      end

      def self.details
        "Overlays an image or text over all icons, using ImageMagick and replacing the old icons.
        Text overlay based off @merowing's script http://merowing.info/2013/03/overlaying-application-version-on-top-of-your-icon/
        Banner overlay based off of @squarefrog's comment https://github.com/KrauseFx/fastlane/issues/481#issuecomment-147368555"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :appiconset_path,
                                       env_name: "FL_ADD_ICON_OVERLAY_APPICONSET_PATH",
                                       description: "Path for .appiconset containing the icons",
                                       is_string: true,
                                       default_value: '**/AppIcon.appiconset'
                                       ),
          FastlaneCore::ConfigItem.new(key: :overlay_image_path,
                                       env_name: "FL_ADD_ICON_OVERLAY_OVERLAY_IMAGE_PATH",
                                       description: "Path for the image that will be overlaid on the icons",
                                       is_string: true,
                                       optional: true,
                                       verify_block: Proc.new do |value|
                                       raise "No overlay image path for AddIconOverlayAction given, pass using `overlay_image_path: 'image_path.png'`".red unless value and not value.empty?
                                       end
                                      ),
          FastlaneCore::ConfigItem.new(key: :overlay_type,
                                       env_name: "FL_ADD_ICON_OVERLAY_OVERLAY_TYPE",
                                       description: "Flag specifying if an image, text or banner will be overlayed over the icon",
                                       is_string: true,
                                       default_value: 'text',
                                       verify_block: Proc.new do |value|
                                         raise "Invalid overlay type provided. Expected 'text' or 'image' and '#{value}' was provided" unless value == "text" or value == "image" or value == "banner"
                                       end
                                      ),
          FastlaneCore::ConfigItem.new(key: :text_background_color,
                                       env_name: "FL_ADD_ICON_OVERLAY_TEXT_BACKGROUND_COLOR",
                                       description: "Background color for the text overlay. If a hex value is provided must contain the '#' character",
                                       is_string: true,
                                       default_value: "#C2C2C3",
                                       optional: true
                                      ),
          FastlaneCore::ConfigItem.new(key: :text_foreground_color,
                                       env_name: "FL_ADD_ICON_OVERLAY_TEXT_FOREGROUND_COLOR",
                                       description: "Foreground color for the text overlay (Text color). If a hex value is provided must contain the '#' character",
                                       is_string: true,
                                       default_value: "white",
                                       optional: true
                                      ),
          FastlaneCore::ConfigItem.new(key: :text_overlay_height,
                                       env_name: "FL_ADD_ICON_OVERLAY_OVERLAY_HEIGHT",
                                       description: "Height of the overlay in respect to the overall height of the icon (e.g. 0.5 for 50%)",
                                       optional: true,
                                       default_value: 0.3,
                                       is_string: false,
                                       verify_block: Proc.new do |value|
                                         raise "Invalid height percentage provided. Must be a float value between 0.0 & 1.0" unless value and value.to_f > 0 and value.to_f <= 1.0
                                       end
                                      ),
          FastlaneCore::ConfigItem.new(key: :text_overlay,
                                       description: "The text to be overlayed over the icon. Can contain '\\t' and '\\n' when 'overlay_type' is 'text', not on 'banner'",
                                       is_string: true,
                                       optional: true
                                      ),
          FastlaneCore::ConfigItem.new(key: :text_overlay_position,
                                       env_name: "FL_ADD_ICON_OVERLAY_TEXT_OVERLAY_POSITION",
                                       description: "Where on the icon the text will be overlayed (south & north). Only available for 'overlay_type' 'text'",
                                       is_string: true,
                                       optional: true,
                                       default_value: "south",
                                       verify_block: proc do |value|
                                         raise "Invalid text overlay position. Expected 'north' or 'south' and '#{value}' provided" unless value and (value == "north" || value == "south")
                                       end
                                      ),
          FastlaneCore::ConfigItem.new(key: :text_overlay_font,
                                       env_name: "FL_ADD_OVERLAY_ICON_FONT",
                                       description: "Name of the font to be used on the text overlay. Must be in font list `convert -list font or full path to font",
                                       is_string: true,
                                       optional: true,
                                       default_value: "Helvetica"
                                       )
        ]
      end

      def self.output
      end

      def self.authors
        ["esttorhe", "marcelofabri"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
