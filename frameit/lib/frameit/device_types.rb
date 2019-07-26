require_relative 'device'
require_relative 'module'
require 'deliver/app_screenshot'

module Frameit
  module Color
    MATTE_BLACK = "Matte Black"
    SPACE_GRAY = "Space Gray"
    ROSE_GOLD = "Rose Gold"
    CLEARLY_WHITE = "Clearly White"
    JUST_BLACK = "Just Black"
    NOT_PINK = "Not Pink"
    SILVER_TITANIUM = "Silver Titanium"
    ARCTIC_SILVER = "Arctic Silver"
    CORAL_BLUE = "Coral Blue"
    MAPLE_GOLD = "Maple Gold"
    MIDNIGHT_BLACK = "Midnight Black"
    ORCHID_GRAY = "Orchid Gray"
    BURGUNDY_RED = "Burgundy Red"
    LILAC_PURPLE = "Lilac Purple"
    SUNRISE_GOLD = "Sunrise Gold"
    TITANIUM_GRAY = "Titanium Gray"
    CORAL = "Coral"
    BLACK = "Black"
    WHITE = "White"
    GOLD = "Gold"
    SILVER = "Silver"
    BLUE = "Blue"
    RED = "Red"
    YELLOW = "Yellow"
    GREEN = "Green"
    PINK = "Pink"
  end

  module Orientation
    PORTRAIT = "PORTRAIT"
    LANDSCAPE = "LANDSCAPE"
  end

  module Platform
    ANDROID = "ANDROID"
    IOS = "IOS"
    ANY = "ANY"

    def self.check_platform(value)
      platform_found = false
      Platform.constants.each do |c|
        if Platform.const_get(c) == value
          platform_found = true
          break
        end
      end

      unless platform_found
        UI.user_error!("Invalid platform type '#{value}'. Available values are IOS, ANDROID or ANY.")
      end
    end
  end

  module Devices
    GOOGLE_PIXEL_3 = Frameit::Device.new("google-pixel-3", "Google Pixel 3", 7, [[1080, 2160], [2160, 1080]], 443, Color::JUST_BLACK, Platform::ANDROID)
    GOOGLE_PIXEL_3_XL = Frameit::Device.new("google-pixel-3-xl", "Google Pixel 3 XL", 7, [[1440, 2960], [2960, 1440]], 523, Color::JUST_BLACK, Platform::ANDROID)
    HTC_ONE_A9 = Frameit::Device.new("htc-one-a9", "HTC One A9", 6, [[1080, 1920], [1920, 1080]], 441, Color::BLACK, Platform::ANDROID)
    HTC_ONE_M8 = Frameit::Device.new("htc-one-m8", "HTC One M8", 3, [[1080, 1920], [1920, 1080]], 441, Color::BLACK, Platform::ANDROID)
    HUAWEI_P8 = Frameit::Device.new("huawei-p8", "Huawei P8", 5, [[1080, 1920], [1920, 1080]], 424, Color::BLACK, Platform::ANDROID)
    MOTOROLA_MOTO_E = Frameit::Device.new("motorola-moto-e", "Motorola Moto E", 3, [[540, 960], [960, 540]], 245, Color::BLACK, Platform::ANDROID)
    MOTOROLA_MOTO_G = Frameit::Device.new("motorola-moto-g", "Motorola Moto G", 4, [[1080, 1920], [1920, 1080]], 401, nil, Platform::ANDROID, nil)
    NEXUS_4 = Frameit::Device.new("nexus-4", "Nexus 4", 7, [[768, 1280], [1820, 768]], 318, nil, Platform::ANDROID)
    NEXUS_5X = Frameit::Device.new("nexus-5x", "Nexus 5X", 7, [[1080, 1920], [1920, 1080]], 423, nil, Platform::ANDROID)
    NEXUS_6P = Frameit::Device.new("nexus-6p", "Nexus 6P", 7, [[1440, 2560], [2560, 1440]], 518, nil, Platform::ANDROID)
    NEXUS_9 = Frameit::Device.new("nexus-9", "Nexus 9", 7, [[1536, 2048], [2048, 1536]], 281, nil, Platform::ANDROID)
    SAMSUNG_GALAXY_GRAND_PRIME = Frameit::Device.new("samsung-galaxy-grand-prime", "Samsung Galaxy Grand Prime", 5, [[540, 960], [960, 540]], 220, Color::BLACK, Platform::ANDROID)
    SAMSUNG_GALAXY_NOTE_5 = Frameit::Device.new("samsung-galaxy-note-5", "Samsung Galaxy Note 5", 5, [[1440, 2560], [2560, 1440]], 518, Color::BLACK, Platform::ANDROID)
    SAMSUNG_GALAXY_S_DUOS = Frameit::Device.new("samsung-galaxy-s-duos", "Samsung Galaxy S Duos", 3, [[480, 800], [800, 480]], 233, nil, Platform::ANDROID)
    SAMSUNG_GALAXY_S3 = Frameit::Device.new("samsung-galaxy-s3", "Samsung Galaxy S3", 3, [[720, 1280], [1280, 720]], 306, nil, Platform::ANDROID)
    SAMSUNG_GALAXY_S5 = Frameit::Device.new("samsung-galaxy-s5", "Samsung Galaxy S5", 3, [[1080, 1920], [1920, 1080]], 432, Color::BLACK, Platform::ANDROID)
    SAMSUNG_GALAXY_S7 = Frameit::Device.new("samsung-galaxy-s7", "Samsung Galaxy S7", 4, [[1440, 2560], [2560, 1440]], 577, Color::BLACK, Platform::ANDROID)
    SAMSUNG_GALAXY_S8 = Frameit::Device.new("samsung-galaxy-s8", "Samsung Galaxy S8", 5, [[1440, 2960], [2960, 1440]], 570, Color::MIDNIGHT_BLACK, Platform::ANDROID)
    SAMSUNG_GALAXY_S9 = Frameit::Device.new("samsung-galaxy-s9", "Samsung Galaxy S9", 6, [[1440, 2960], [2960, 1440]], 570, Color::MIDNIGHT_BLACK, Platform::ANDROID)
    IPHONE_5S = Frameit::Device.new("iphone-5s", "Apple iPhone 5s", 2, [[640, 1096], [640, 1136], [1136, 600], [1136, 640]], 326, Color::SPACE_GRAY, Platform::IOS, Deliver::AppScreenshot::ScreenSize::IOS_40, :use_legacy_iphone5s)
    IPHONE_5C = Frameit::Device.new("iphone-5c", "Apple iPhone 5c", 2, [[640, 1136], [1136, 640]], 326, Color::WHITE)
    IPHONE_SE = Frameit::Device.new("iphone-se", "Apple iPhone SE", 3, [[640, 1096], [640, 1136], [1136, 600], [1136, 640]], 326, Color::SPACE_GRAY, Platform::IOS, Deliver::AppScreenshot::ScreenSize::IOS_40)
    IPHONE_6S = Frameit::Device.new("iphone-6s", "Apple iPhone 6s", 4, [[750, 1334], [1334, 750]], 326, Color::SPACE_GRAY, Platform::IOS, Deliver::AppScreenshot::ScreenSize::IOS_47, :use_legacy_iphone6s)
    IPHONE_6S_PLUS = Frameit::Device.new("iphone-6s-plus", "Apple iPhone 6s Plus", 4, [[1242, 2208], [2208, 1242]], 401, Color::SPACE_GRAY, Platform::IOS, Deliver::AppScreenshot::ScreenSize::IOS_55, :use_legacy_iphone6s)
    IPHONE_7 = Frameit::Device.new("iphone-7", "Apple iPhone 7", 5, [[750, 1334], [1334, 750]], 326, Color::MATTE_BLACK, Platform::IOS, Deliver::AppScreenshot::ScreenSize::IOS_47, :use_legacy_iphone7)
    IPHONE_7_PLUS = Frameit::Device.new("iphone-7-plus", "Apple iPhone 7 Plus", 5, [[1242, 2208], [2208, 1242]], 401, Color::MATTE_BLACK, Platform::IOS, Deliver::AppScreenshot::ScreenSize::IOS_55, :use_legacy_iphone7)
    IPHONE_8 = Frameit::Device.new("iphone-8", "Apple iPhone 8", 6, [[750, 1334], [1334, 750]], 326, Color::SPACE_GRAY)
    IPHONE_8_PLUS = Frameit::Device.new("iphone-8-plus", "Apple iPhone 8 Plus", 6, [[1080, 1920], [1920, 1080]], 401, Color::SPACE_GRAY)
    IPHONE_X = Frameit::Device.new("iphone-X", "Apple iPhone X", 7, [[1125, 2436], [2436, 1125]], 458, Color::SPACE_GRAY, Platform::IOS, Deliver::AppScreenshot::ScreenSize::IOS_58, :use_legacy_iphonex)
    IPHONE_XS = Frameit::Device.new("iphone-XS", "Apple iPhone XS", 8, [[1125, 2436], [2436, 1125]], 458, Color::SPACE_GRAY, Platform::IOS, Deliver::AppScreenshot::ScreenSize::IOS_58)
    IPHONE_XR = Frameit::Device.new("iphone-XR", "Apple iPhone XR", 8, [[828, 1792], [1792, 828]], 326, Color::SPACE_GRAY, Platform::IOS, Deliver::AppScreenshot::ScreenSize::IOS_61)
    IPHONE_XS_MAX = Frameit::Device.new("iphone-XS-Max", "Apple iPhone XS Max", 8, [[1242, 2688], [2688, 1242]], 458, Color::SPACE_GRAY, Platform::IOS, Deliver::AppScreenshot::ScreenSize::IOS_65)
    IPAD_AIR_2 = Frameit::Device.new("ipad-air-2", "Apple iPad Air 2", 1, [[1536, 2048], [2048, 1536]], 264, Color::SPACE_GRAY, Platform::IOS, Deliver::AppScreenshot::ScreenSize::IOS_IPAD)
    IPAD_MINI_4 = Frameit::Device.new("ipad-mini-4", "Apple iPad Mini 4", 2, [[1536, 2048], [2048, 1536]], 324, Color::SPACE_GRAY)
    IPAD_PRO = Frameit::Device.new("ipad-pro", "Apple iPad Pro", 3, [[2048, 2732], [2732, 2048]], 264, Color::SPACE_GRAY, Platform::IOS, Deliver::AppScreenshot::ScreenSize::IOS_IPAD_PRO)
    # iPad Pro (12.9-inch) (3rd generation) is not in frameit-frames repo, but must be included so that we are backward compatible with PR #14787
    # priority must be lower than IPAD_PRO so that users who didn't copy the frame to their frameit frames folder will not get an error
    # ID and formatted name must be exactly as specified so that device.detect_device() will select this device if the filename includes them
    IPAD_PRO_12_9 = Frameit::Device.new("ipadPro129", "Apple iPad Pro (12.9-inch) (3rd generation)", 2, [[2048, 2732], [2732, 2048]], 264, Color::SPACE_GRAY, Platform::IOS, Deliver::AppScreenshot::ScreenSize::IOS_IPAD_PRO_12_9)
    MAC = Frameit::Device.new("mac", "Apple MacBook", 0, [[1280, 800], [1440, 900], [2560, 1600], [2880, 1800]], nil, Color::SPACE_GRAY, Platform::IOS, Deliver::AppScreenshot::ScreenSize::MAC)
  end
end
