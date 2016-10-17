module Frameit
  class Offsets
    # Returns the image offset needed for a certain device type for a given orientation
    # uses deliver to detect the screen size
    def self.image_offset(screenshot)
      require 'json'

      unless @offsets
        offsets_json_path = File.join(FrameDownloader.new.templates_path, "offsets.json")
        UI.user_error!("Could not find offsets.json file at path '#{offsets_json_path}'") unless File.exist?(offsets_json_path)
        @offsets = JSON.parse(File.read(offsets_json_path))
      end

      return @offsets["portrait"][screenshot.device_name]

      # TODO: Remove all that
      size = Deliver::AppScreenshot::ScreenSize
      case screenshot.orientation_name
      when Orientation::PORTRAIT
        case screenshot.screen_size
        when size::IOS_55
          return {
            'offset' => '+41+146',
            'width' => 541
          }
        when size::IOS_47
          return {
            'offset' => "+43+154",
            'width' => 530
          }
        when size::IOS_40
          if Frameit.config[:use_legacy_iphone5s]
            return {
              'offset' => "+54+197",
              'width' => 544
            }
          else
            return {
             'offset' => "+48+178",
             'width' => 485
            }
          end
        when size::IOS_35
          return {
            'offset' => "+59+260",
            'width' => 647
          }
        when size::IOS_IPAD
          return {
            'offset' => '+47+135',
            'width' => 737
          }
        when size::IOS_IPAD_PRO
          return {
            'offset' => '+48+90',
            'width' => 805
          }
        end
      end
    end
  end
end
