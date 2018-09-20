require 'fastlane_core/command_executor'

module Match
  module Storage
    # Store the code signing identities in a git repo
    class GitStorage
      def initialize
        not_implemented(__method__)
      end

      def configure
        not_implemented(__method__)
      end

      def download
        not_implemented(__method__)
      end

      def save_changes!
        not_implemented(__method__)
      end

      def clear_changes
        not_implemented(__method__)
      end
    end
  end
end
