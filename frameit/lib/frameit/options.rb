require 'fastlane_core/configuration/config_item'

require_relative 'module'

module Frameit
  class Options
    def self.available_options
      @options ||= [

        FastlaneCore::ConfigItem.new(key: :white,
                                       env_name: "FRAMEIT_WHITE_FRAME",
                                       description: "Use white device frames",
                                       optional: true,
                                       is_string: false),
        FastlaneCore::ConfigItem.new(key: :silver,
                                     description: "Use white device frames. Alias for :white",
                                     optional: true,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :rose_gold,
                                     description: "Use rose gold device frames. Alias for :rose_gold",
                                     optional: true,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :gold,
                                     description: "Use gold device frames. Alias for :gold",
                                     optional: true,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :force_device_type,
                                     env_name: "FRAMEIT_FORCE_DEVICE_TYPE",
                                     description: "Forces a given device type, useful for Mac screenshots, as their sizes vary",
                                     optional: true,
                                     verify_block: proc do |value|
                                       available = ['iPhone_6_Plus', 'iPhone_5s', 'iPhone_4', 'iPad_mini', 'Mac']
                                       unless available.include?(value)
                                         UI.user_error!("Invalid device type '#{value}'. Available values: #{available}")
                                       end
                                     end),
        FastlaneCore::ConfigItem.new(key: :use_legacy_iphone5s,
                           env_name: "FRAMEIT_USE_LEGACY_IPHONE_5_S",
                           is_string: false,
                           description: "Use iPhone 5s instead of iPhone SE frames",
                           default_value: false),
        FastlaneCore::ConfigItem.new(key: :use_legacy_iphone6s,
                           env_name: "FRAMEIT_USE_LEGACY_IPHONE_6_S",
                           is_string: false,
                           description: "Use iPhone 6s frames instead of iPhone 7 frames",
                           default_value: false),
        FastlaneCore::ConfigItem.new(key: :force_orientation_block,
                           type: :string_callback,
                           description: "[Advanced] A block to customize your screnshots' device orientation",
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
                           default_value_dynamic: true)
      ]
    end
  end
end
