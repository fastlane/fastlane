module Fastlane
  module Helper
    class GradleTask
      attr_accessor :title

      attr_accessor :description

      def initialize(title: nil, description: nil)
        self.title = title
        self.description = description
      end
    end

    class GradleHelper
      # Path to the gradle script
      attr_accessor :gradle_path

      # Read-only path to the shell-escaped gradle script, suitable for use in shell commands
      attr_reader :escaped_gradle_path

      # All the available tasks
      attr_accessor :tasks

      def initialize(gradle_path: nil)
        self.gradle_path = gradle_path
      end

      # Run a certain action
      def trigger(task: nil, flags: nil, serial: nil, print_command: true, print_command_output: true)
        android_serial = (serial != "") ? "ANDROID_SERIAL=#{serial}" : nil
        command = [android_serial, escaped_gradle_path, task, flags].compact.join(" ")
        Action.sh(command, print_command: print_command, print_command_output: print_command_output)
      end

      def task_available?(task)
        load_all_tasks
        return tasks.collect(&:title).include?(task)
      end

      def gradle_path=(gradle_path)
        @gradle_path = gradle_path
        @escaped_gradle_path = gradle_path.shellescape
      end

      private

      def load_all_tasks
        self.tasks = []

        command = [escaped_gradle_path, "tasks", "--console=plain"].join(" ")
        output = Action.sh(command, print_command: false, print_command_output: false)
        output.split("\n").each do |line|
          if (result = line.match(/(\w+)\s\-\s([\w\s]+)/))
            self.tasks << GradleTask.new(title: result[1], description: result[2])
          end
        end

        self.tasks
      end
    end
  end
end
