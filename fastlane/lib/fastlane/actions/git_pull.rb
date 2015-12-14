module Fastlane
  module Actions
    class GitPullAction < Action
      def self.run(params)
        command = [
          'git',
          'pull',
          '--tags'
        ]

        Actions.sh(command.join(' '))
        Helper.log.info 'Sucesfully pulled from remote.'
      end

      def self.description
        "Executes a simple git pull command"
      end

      def self.available_options
        [
        ]
      end

      def self.author
        "KrauseFx"
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
