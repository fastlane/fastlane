module Fastlane
  class SupportedPlatforms
    def self.all
      [
        :ios,
        :mac,
        :android
      ]
    end

    # this will throw an exception if the passed platform is not supported
    def self.verify!(platform)
      unless all.include? platform.to_s.to_sym
        raise "Platform '#{platform}' is not supported. Must be either #{self.all}".red
      end
    end
  end
end
