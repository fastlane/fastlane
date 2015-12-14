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

      # All the available tasks
      attr_accessor :tasks

      def initialize(gradle_path: nil)
        self.gradle_path = gradle_path
      end

      # Run a certain action
      def trigger(task: nil, flags: nil)
        # raise "Could not find gradle task '#{task}' in the list of available tasks".red unless task_available?(task)

        command = [gradle_path, task, flags].join(" ")
        Action.sh(command)
      end

      def task_available?(task)
        load_all_tasks
        return tasks.collect(&:title).include?(task)
      end

      private

      def load_all_tasks
        self.tasks = []

        command = [gradle_path, "tasks", "--console=plain"].join(" ")
        output = Actions.sh(command, log: false)
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
