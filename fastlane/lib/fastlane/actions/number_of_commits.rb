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

      def self.details
        "You can use this action to get the number of commits of this repo. This is useful if you want to set the build number to the number of commits."
      end

      def self.authors
        ["onevcat"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'build_number = number_of_commits
          increment_build_number(build_number: build_number)'
        ]
      end

      def self.category
        :source_control
      end
    end
  end
end
