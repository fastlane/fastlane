module Fastlane
  module Actions
    class NumberOfCommitsAction < Action
      def self.is_git?
        Actions.sh('git rev-parse HEAD')
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
          end
        else
          UI.user_error!("Not in a git repository.")
        end
        return Actions.sh(command).strip.to_i
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Return the number of commits in current git branch"
      end

      def self.return_value
        "The total number of all commits in current git branch"
      end

      def self.return_type
        :int
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :all,
                                       env_name: "FL_NUMBER_OF_COMMITS_ALL",
                                       optional: true,
                                       is_string: false,
                                       description: "Returns number of all commits instead of current branch")
        ]
      end

      def self.details
        "You can use this action to get the number of commits of this branch. This is useful if you want to set the build number to the number of commits. See `fastlane actions number_of_commits` for more details."
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
          increment_build_number(build_number: number_of_commits)'
        ]
      end

      def self.category
        :source_control
      end
    end
  end
end
