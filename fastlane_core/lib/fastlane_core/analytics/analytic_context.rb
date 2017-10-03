module FastlaneCore
  class AnalyticContext
    def initialize(options)
      options.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end
  end
end
