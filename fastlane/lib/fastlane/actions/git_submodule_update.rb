module Fastlane
  module Actions
    class GitSubmoduleUpdateAction < Action
      def self.run(params)
        commands = ["git submodule update"]
        commands += ["--init"] if params[:init]
        commands += ["--recursive"] if params[:recursive]
        Actions.sh(commands.join(' '))
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Executes a git submodule update command"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :recursive,
                                       description: "Should the submodules be updated recursively?",
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :init,
                                       description: "Should the submodules be initiated before update?",
                                       type: Boolean,
                                       default_value: false)
        ]
      end

      def self.output
      end

      def self.return_value
      end

      def self.authors
        ["braunico"]
      end

      def self.is_supported?(platform)
        return true
      end

      def self.example_code
        [
          'git_submodule_update',
          'git_submodule_update(recursive: true)',
          'git_submodule_update(init: true)',
          'git_submodule_update(recursive: true, init: true)'
        ]
      end

      def self.category
        :source_control
      end
    end
  end
end
