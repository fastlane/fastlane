module Fastlane
  module Actions
    module SharedValues
      GRADLE_APK_OUTPUT_PATH = :APK_OUTPUT_PATH
      GRADLE_FLAVOR = :GRADLE_FLAVOR
    end

    class GradleAction < Action
      def self.run(params)
        task = params[:task]

        gradle = Helper::GradleHelper.new(gradle_path: params[:gradle_path])

        result = gradle.trigger(task: task, flags: params[:flags])

        return result unless task.start_with?("assemble")

        # We built our app. Store the path to the apk
        flavor = task.match(/assemble(\w*)/)
        if flavor and flavor[1]
          flavor = flavor[1].downcase # Release => release
          apk_path = Dir[File.join("app", "build", "outputs", "apk", "*-#{flavor}.apk")].last
          if apk_path
            Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH] = File.expand_path(apk_path)
          else
            Helper.log.info "Couldn't find signed apk file at path '#{apk_path}'...".red
            if flavor == 'release'
              Helper.log.info "Make sure to enable code signing in your gradle task: ".red
              Helper.log.info "https://stackoverflow.com/questions/18328730/how-to-create-a-release-signed-apk-file-using-gradle".red
            end
          end
          Actions.lane_context[SharedValues::GRADLE_FLAVOR] = flavor
        end

        return result
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
                                         raise "Couldn't find gradlew at path '#{File.expand_path(value)}'".red unless File.exist?(value)
                                       end)
        ]
      end

      def self.output
        [
          ['APK_OUTPUT_PATH', 'The path to the newly generated apk file']
        ]
      end

      def self.return_value
        "The output of running the gradle task"
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
