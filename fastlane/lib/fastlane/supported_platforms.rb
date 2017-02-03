module Fastlane
  class SupportedPlatforms
    def self.all
      [
        :ios,
        :mac,
        :android
      ]
    end

    # this will log a warning if the passed platform is not supported
    def self.verify!(platform)
      unless all.include? platform.to_s.to_sym
        UI.important("Platform '#{platform}' is not officially supported. Currently supported plaforms are #{self.all}.")
      end
    end
  end
end
