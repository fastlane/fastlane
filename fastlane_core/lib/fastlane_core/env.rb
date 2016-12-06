module FastlaneCore
  class Env
    def self.enabled?(env)
      return false unless ENV[env]
      unless ENV["SKIP_ENV_HANDLER"]
        return false if ["no", "false", "off"].include?(ENV[env].to_s)
      end
      # if SKIP_ENV_HANDLER is set this should fallback to previous behaviour
      return ENV[env]
    end
  end
end
