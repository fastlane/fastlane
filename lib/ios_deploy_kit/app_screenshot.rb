module IosDeployKit
  module ScreenSize
    IOS_35 = "iOS-3.5-in"
    IOS_40 = "iOS-4-in"
    IOS_47 = "iOS-4.7-in"
    IOS_55 = "iOS-5.5-in"
    IOS_IPAD = "iOS-iPad"
  end

  class AppScreenshot
    attr_accessor :path, :screen_size
    def initialize(path, screen_size)
      raise "Screenshot not found at path '#{path}'" unless File.exists?path

      self.path = path
      self.screen_size = screen_size
    end
  end
end