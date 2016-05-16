module Fastlane
  module Actions
    class XcakeAction < Action
      def self.run(params)
        Actions.verify_gem!('xcake')
        require 'xcake'

        if defined? Xcake::Command::Make
          # New `xcake make` command
          Xcake::Command::Make.run
        else
          # Legacy `xcake` command
          Xcake::Command.run
        end
      end

      def self.description
        "Runs `xcake` for the project"
      end

      def self.available_options
        [
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end

      def self.authors
        ["jcampbell05"]
      end
    end
  end
end
