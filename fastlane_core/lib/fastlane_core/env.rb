module FastlaneCore
  class Env
    def self.enabled?(env)
      return false unless ENV[env]
      unless ENV["SKIP_ENV_HANDLER"]
        return false if ["no", "false", "off"].include(ENV[env].to_s)
      end
      return true
    end
  end
end
