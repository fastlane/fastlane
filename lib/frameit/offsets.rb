module Frameit
  class Offsets
    # Returns the image offset needed for a certain device type for a given orientation
    # uses deliver to detect the screen size
    # rubocop:disable Metrics/MethodLength
    def self.image_offset(screenshot)
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
          return {
            'offset' => "+54+197",
            'width' => 544
          }
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
      when Orientation::LANDSCAPE
        case screenshot.screen_size
        when size::IOS_55
          return {
            'offset' => "+146+41",
            'width' => 960
          }
        when size::IOS_47
          return {
            'offset' => "+153+41",
            'width' => 946
          }
        when size::IOS_40
          return {
            'offset' => "+201+48",
            'width' => 970
          }
        when size::IOS_35
          return {
            'offset' => "+258+52",
            'width' => 966
          }
        when size::IOS_IPAD
          return {
            'offset' => '+135+47',
            'width' => 983
          }
        when size::IOS_IPAD_PRO
          return {
            'offset' => '+88+48',
            'width' => 1075
          }
        end
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
