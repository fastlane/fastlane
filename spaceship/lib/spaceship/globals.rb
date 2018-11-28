module Spaceship
  class Globals
    # if spaceship is run with a FastlaneCore available respect the global state there
    # otherwise fallback to $verbose
    def self.verbose?
      if Object.const_defined?("FastlaneCore")
        return FastlaneCore::Globals.verbose? # rubocop:disable Require/MissingRequireStatement
      end
      return $verbose
    end
  end
end
