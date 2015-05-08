module Frameit
  class Offsets
    # Returns the image offset needed for a certain device type for a given orientation
    # uses deliver to detect the screen size
    def self.image_offset(screenshot)
      size = Deliver::AppScreenshot::ScreenSize
      case screenshot.orientation_name
        when Orientation::PORTRAIT
          case screenshot.screen_size
            when size::IOS_55
              return { 
                offset: '+42+147',
                width: 539
              }
            when size::IOS_47
              return {
                offset: '+41+154',
                width: 530
              }
            when size::IOS_40
              return {
                offset: "+54+197",
                width: 543
              }
            when size::IOS_IPAD
              return {
                offset: '+50+134',
                width: 792
              }
          end
        when Orientation::LANDSCAPE
          case screenshot.screen_size
            when size::IOS_55
              return { 
                offset: "+146+41",
                width: 960
              }
            when size::IOS_47
              return {
                offset: "+153+41",
                width: 946
              }
            when size::IOS_40
              return {
                offset: "+201+48",
                width: 970
              }
            when size::IOS_35
              return {
                offset: "+258+62",
                width: 966
              }
            when size::IOS_IPAD
              return {
                offset: '+133+50',
                width: 1058
              }
          end
      end
    end
  end
end