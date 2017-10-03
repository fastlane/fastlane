module FastlaneCore
  class AnalyticsContext
    def initialize(options)
      options.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end
  end
end
