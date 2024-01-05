module Fastlane
  class SupportedPlatforms
    class << self
      attr_accessor :extra
      attr_reader :default

      def extra=(value)
        value ||= []
        UI.important("Setting '#{value}' as extra SupportedPlatforms")
        @extra = value
      end
    end

    @default = [:ios, :mac, :android]
    @extra = []

    def self.all
      (@default + @extra).flatten
    end

    # this will log a warning if the passed platform is not supported
    def self.verify!(platform)
      unless all.include?(platform.to_s.to_sym)
        UI.important("Platform '#{platform}' is not officially supported. Currently supported platforms are #{self.all}.")
      end
    end
  end
end
