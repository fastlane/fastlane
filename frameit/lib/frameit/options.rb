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
        FastlaneCore::ConfigItem.new(key: :force_device_type,
                                     env_name: "FRAMEIT_FORCE_DEVICE_TYPE",
                                     description: "Forces a given device type, useful for Mac screenshots, as their sizes vary",
                                     optional: true,
                                     verify_block: proc do |value|
                                       available = ['iPhone_7_Plus', 'iPhone_5s', 'iPhone_4', 'iPad_mini', 'Mac']
                                       unless available.include? value
                                         UI.user_error!("Invalid device type '#{value}'. Available values: #{available}")
                                       end
                                     end),
        FastlaneCore::ConfigItem.new(key: :use_legacy_iphone5s,
                           env_name: "FRAMEIT_USE_LEGACY_IPHONE_5_S",
                           optional: true,
                           is_string: false,
                           description: "use iPhone 5s instead of iPhone SE frames",
                           default_value: false)
      ]
    end
  end
end
