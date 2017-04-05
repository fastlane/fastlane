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
          if params[:all]
            command = 'git rev-list --all --count'
          else
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
        "Return the total number of all commits in current git branch"
      end

      def self.return_value
        "The total number of all commits in current git branch"
      end

      def self.details
        "You can use this action to get the number of commits of this branch. This is useful if you want to set the build number to the number of commits. If you want all the commits in the current repo, set the `all` parameter to true."
      end

      def self.authors
        ["onevcat", "samuelbeek"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'increment_build_number(build_number: number_of_commits)',
          'build_number = number_of_commits(all: true)
          increment_build_number(build_number: number_of_commits)',
        ]
      end

      def self.category
        :source_control
      end
    end
  end
end
