module Review
  class RuleViolation
    def initialize(app, severity)
      @app = app
    end
  end
end
