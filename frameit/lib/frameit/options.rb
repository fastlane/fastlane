require 'fastlane_core/configuration/config_item'
require 'fastlane/actions/actions_helper'
require 'fastlane/helper/lane_helper'

require_relative 'module'
require_relative 'config_parser'
require_relative 'device_types'

module Frameit
  class Options
    def self.available_options
      @options ||= [

        FastlaneCore::ConfigItem.new(key: :white,
                                       env_name: "FRAMEIT_WHITE_FRAME",
                                       description: "Use white device frames",
                                       type: Boolean,
                                       optional: true),
        FastlaneCore::ConfigItem.new(key: :silver,
                                       env_name: "FRAMEIT_SILVER_FRAME",
                                       description: "Use white device frames. Alias for :white",
                                       type: Boolean,
                                       optional: true),
        FastlaneCore::ConfigItem.new(key: :rose_gold,
                                       env_name: "FRAMEIT_ROSE_GOLD_FRAME",
                                       description: "Use rose gold device frames. Alias for :rose_gold",
                                       type: Boolean,
                                       optional: true),
        FastlaneCore::ConfigItem.new(key: :gold,
                                       env_name: "FRAMEIT_GOLD_FRAME",
                                       description: "Use gold device frames. Alias for :gold",
                                       type: Boolean,
                                       optional: true),
        FastlaneCore::ConfigItem.new(key: :force_device_type,
                                       env_name: "FRAMEIT_FORCE_DEVICE_TYPE",
                                       description: "Forces a given device type, useful for Mac screenshots, as their sizes vary",
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Invalid device type '#{value}'. Available values: " + Devices.all_device_names_without_apple.join(', ')) unless ConfigParser.supported_device?(value)
                                       end),
        FastlaneCore::ConfigItem.new(key: :use_legacy_iphone5s,
                                       env_name: "FRAMEIT_USE_LEGACY_IPHONE_5_S",
                                       description: "Use iPhone 5s instead of iPhone SE frames",
                                       default_value: false,
                                       type: Boolean),
        FastlaneCore::ConfigItem.new(key: :use_legacy_iphone6s,
                                       env_name: "FRAMEIT_USE_LEGACY_IPHONE_6_S",
                                       description: "Use iPhone 6s frames instead of iPhone 7 frames",
                                       default_value: false,
                                       type: Boolean),
        FastlaneCore::ConfigItem.new(key: :use_legacy_iphone7,
                                       env_name: "FRAMEIT_USE_LEGACY_IPHONE_7",
                                       description: "Use iPhone 7 frames instead of iPhone 8 frames",
                                       default_value: false,
                                       type: Boolean),
        FastlaneCore::ConfigItem.new(key: :use_legacy_iphonex,
                                       env_name: "FRAMEIT_USE_LEGACY_IPHONE_X",
                                       description: "Use iPhone X instead of iPhone XS frames",
                                       default_value: false,
                                       type: Boolean),
        FastlaneCore::ConfigItem.new(key: :use_legacy_iphonexr,
                                     env_name: "FRAMEIT_USE_LEGACY_IPHONE_XR",
                                     description: "Use iPhone XR instead of iPhone 11 frames",
                                     default_value: false,
                                     type: Boolean),
        FastlaneCore::ConfigItem.new(key: :use_legacy_iphonexs,
                                     env_name: "FRAMEIT_USE_LEGACY_IPHONE_XS",
                                     description: "Use iPhone XS instead of iPhone 11 Pro frames",
                                     default_value: false,
                                     type: Boolean),
        FastlaneCore::ConfigItem.new(key: :use_legacy_iphonexsmax,
                                     env_name: "FRAMEIT_USE_LEGACY_IPHONE_XS_MAX",
                                     description: "Use iPhone XS Max instead of iPhone 11 Pro Max frames",
                                     default_value: false,
                                     type: Boolean),
        FastlaneCore::ConfigItem.new(key: :force_orientation_block,
                                       type: :string_callback,
                                       description: "[Advanced] A block to customize your screenshots' device orientation",
                                       display_in_shell: false,
                                       optional: true,
                                       default_value: proc do |filename|
                                         f = filename.downcase
                                         if f.end_with?("force_landscapeleft")
                                           :landscape_left
                                         elsif f.end_with?("force_landscaperight")
                                           :landscape_right
                                         end
                                       end,
                                       default_value_dynamic: true),
        FastlaneCore::ConfigItem.new(key: :debug_mode,
                                       env_name: "FRAMEIT_DEBUG_MODE",
                                       description: "Output debug information in framed screenshots",
                                       default_value: false,
                                       type: Boolean),
        FastlaneCore::ConfigItem.new(key: :resume,
                                       env_name: "FRAMEIT_RESUME",
                                       description: "Resume frameit instead of reprocessing all screenshots",
                                       default_value: false,
                                       type: Boolean),
        FastlaneCore::ConfigItem.new(key: :use_platform,
                                       env_name: "FRAMEIT_USE_PLATFORM",
                                       description: "Choose a platform, the valid options are IOS, ANDROID and ANY (default is either general platform defined in the fastfile or IOS to ensure backward compatibility)",
                                       optional: true,
                                       default_value: Platform.symbol_to_constant(Fastlane::Helper::LaneHelper.current_platform),
                                       default_value_dynamic: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Invalid platform type '#{value}'. Available values are " + Platform.all_platforms.join(', ') + ".") unless ConfigParser.supported_platform?(value)
                                       end)
      ]
    end
  end
end
