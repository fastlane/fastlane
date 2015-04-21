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
        fail "Platform '#{platform}' is not supported. Must be either #{all}".red
      end
    end
  end
end
