module FastlaneCore
  class Env
    def self.truthy?(env)
      return false unless ENV[env]
      return false if ["no", "false", "off", "0"].include?(ENV[env].to_s)
      return true
    end
  end
end
