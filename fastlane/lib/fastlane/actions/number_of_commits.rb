module Fastlane
  module Actions
    class NumberOfCommitsAction < Action
      def self.is_git?
        Actions.sh 'git rev-parse HEAD'
        return true
      rescue
        return false
      end

      def self.run(params)
        if is_git?
          command = 'git rev-list HEAD --count'
        else
          UI.user_error!("Not in a git repository.")
        end
        return Actions.sh(command).strip.to_i
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Return the total number of all commits in current git repo"
      end

      def self.return_value
        "The total number of all commits in current git repo"
      end

      def self.authors
        ["onevcat"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
