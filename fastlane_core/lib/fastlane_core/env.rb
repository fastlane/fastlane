module FastlaneCore
  class Env
    def self.enabled?(env)
      return false unless ENV[env]
      unless ENV["SKIP_ENV_HANDLER"]
        return false if ENV[env].to_s == "0"
        return false if ENV[env].to_s == "false"
      end
      return true
    end
  end
end
