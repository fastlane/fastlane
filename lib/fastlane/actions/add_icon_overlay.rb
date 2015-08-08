module Fastlane
  module Actions

    class AddIconOverlayAction < Action
      def self.run(params)
        Helper.log.info "Image to overlay on icons: #{params[:overlay_image_path]}"

        require 'mini_magick'

        appiconset = params[:appiconset_path]

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
        "Overlays an image over all icons, using ImageMagick and replacing the old icons"
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
                                       verify_block: Proc.new do |value|
                                          raise "No overlay image path for AddIconOverlayAction given, pass using `overlay_image_path: 'image_path.png'`".red unless (value and not value.empty?)
                                       end)
        ]
      end

      def self.output
      end

      def self.authors
        ["marcelofabri"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end