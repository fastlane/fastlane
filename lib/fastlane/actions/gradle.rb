module Fastlane
  module Actions
    class GradleAction < Action
      def self.run(params)
        task = params[:task]

        gradle = Helper::GradleHelper.new(gradle_path: params[:gradle_path])

        gradle.trigger(task: task, flags: params[:flags])
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "All gradle related actions, including building and testing your Android app"
      end

      def self.details
        [
          "Run `./gradlew tasks` to get a list of all available gradle tasks for your project"
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :task,
                                       env_name: "FL_GRADLE_TASK",
                                       description: "The gradle task you want to execute",
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :flags,
                                       env_name: "FL_GRADLE_FLAGS",
                                       description: "All parameter flags you want to pass to the gradle command, e.g. `--exitcode --xml file.xml`",
                                       optional: true,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :gradle_path,
                                       env_name: "FL_GRADLE_PATH",
                                       description: "The path to your `gradlew`",
                                       is_string: true,
                                       default_value: Dir["./gradlew"].last, # Using Dir to be nil when the file doesn't exist (import for validation)
                                       verify_block: proc do |value|
                                        raise "Couldn't find gradle file at path '#{File.expand_path(value)}'".red unless File.exist?(value)
                                       end)
        ]
      end

      def self.output
        
      end

      def self.return_value
        # TODO
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        platform == :android
      end
    end
  end
end
