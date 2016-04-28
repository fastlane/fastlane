module Frameit
  class Options
    def self.available_options
      @options ||= [
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
