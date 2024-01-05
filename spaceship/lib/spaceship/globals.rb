module Spaceship
  class Globals
    class << self
      attr_writer(:check_session)
    end

    # if spaceship is run with a FastlaneCore available respect the global state there
    # otherwise fallback to $verbose
    def self.verbose?
      if Object.const_defined?("FastlaneCore")
        return FastlaneCore::Globals.verbose? # rubocop:disable Require/MissingRequireStatement
      end
      return $verbose
    end

    # if spaceship is run with the --check_session flag this value will be set to true
    def self.check_session
      return @check_session
    end
  end
end
