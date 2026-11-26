module Spaceship
  class Globals
    class << self
      attr_writer(:check_session)
    end

    # if spaceship is run with a FastlaneCore available respect the global state there
    # otherwise fallback to $verbose
    def self.verbose?
      if Object.const_defined?("FastlaneCore") && FastlaneCore.const_defined?("Globals")
        return FastlaneCore::Globals.verbose?
      end
      return $verbose
    end

    # Same reading as FastlaneCore::Env.truthy?, which spaceship can't depend on
    def self.env_truthy?(name)
      return false unless ENV[name]
      !["no", "false", "off", "0"].include?(ENV[name].downcase)
    end

    # if spaceship is run with the --check_session flag this value will be set to true
    def self.check_session
      return @check_session
    end
  end
end
