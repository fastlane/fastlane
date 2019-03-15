module Fastlane
  module Actions
    class SpaceshipLogsAction < Action
      def self.run(params)
        latest = params[:latest]
        print_contents = params[:print_contents]
        print_paths = params[:print_paths]
        copy_to_path = params[:copy_to_path]
        copy_to_clipboard = params[:copy_to_clipboard]

        # Get log files
        files = Dir.glob("/tmp/spaceship*.log").sort_by { |f| File.mtime(f) }.reverse

        if files.size == 0
          UI.message("No Spaceship log files found")
          return []
        end

        # Filter to latest
        if latest
          files = [files.first]
        end

        # Print contents
        if print_contents
          files.each do |file|
            data = File.read(file)
            puts("-----------------------------------------------------------------------------------")
            puts(" Spaceship Log Content - #{file}")
            puts("-----------------------------------------------------------------------------------")
            puts(data)
            puts("\n")
          end
        end

        # Print paths
        if print_paths
          puts("-----------------------------------------------------------------------------------")
          puts(" Spaceship Log Paths")
          puts("-----------------------------------------------------------------------------------")
          files.each do |file|
            puts(file)
          end
          puts("\n")
        end

        # Copy to a directory
        if copy_to_path
          require 'fileutils'
          FileUtils.mkdir_p(copy_to_path)
          files.each do |file|
            FileUtils.cp(file, copy_to_path)
          end
        end

        # Copy contents to clipboard
        if copy_to_clipboard
          string = files.map { |file| File.read(file) }.join("\n")
          ClipboardAction.run(value: string)
        end

        return files
      end

      def self.description
        "Find, print, and copy Spaceship logs"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :latest,
                                       description: "Finds only the latest Spaceshop log file if set to true, otherwise returns all",
                                       default_value: true,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :print_contents,
                                       description: "Prints the contents of the found Spaceship log file(s)",
                                       default_value: false,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :print_paths,
                                       description: "Prints the paths of the found Spaceship log file(s)",
                                       default_value: false,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :copy_to_path,
                                       description: "Copies the found Spaceship log file(s) to a directory",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :copy_to_clipboard,
                                       description: "Copies the contents of the found Spaceship log file(s) to the clipboard",
                                       default_value: false,
                                       type: Boolean)
        ]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'spaceship_logs',
          'spaceship_logs(
            copy_to_path: "/tmp/artifacts"
          )',
          'spaceship_logs(
            copy_to_clipboard: true
          )',
          'spaceship_logs(
            print_contents: true,
            print_paths: true
          )',
          'spaceship_logs(
            latest: false,
            print_contents: true,
            print_paths: true
          )'
        ]
      end

      def self.category
        :misc
      end

      def self.return_value
        "The array of Spaceship logs"
      end

      def self.return_type
        :array
      end

      def self.author
        "joshdholtz"
      end
    end
  end
end
