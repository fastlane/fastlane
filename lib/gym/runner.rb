require 'pty'
require 'open3'

module Gym
  class Runner
    def run
      print_summary
      build_app
      verify_archive
      package_app
      move_results
    end

    private

    #####################################################
    # @!group Printing out things
    #####################################################

    def print_summary
      config = Gym.config
      rows = []
      rows << ["Project", config[:project]] if config[:project]
      rows << ["Workspace", config[:workspace]] if config[:workspace]
      rows << ["Scheme", config[:scheme]] if config[:scheme]

      puts Terminal::Table.new(
        title: "Building Application".green,
        rows: rows
      )
      puts ""
    end

    # @param [Array] An array containing all the parts of the command
    def print_command(command, title)
      rows = command.map do |c|
        current = c.to_s.dup
        next unless current.length > 0

        if current.include? "-" and current.to_s.split(" ").count == 2
          # That's a default parameter, like `-project Name`
          current.split(" ")
        else
          current.gsub!("| ", "") # as the | will somehow break the terminal table
          [current, ""]
        end
      end

      puts Terminal::Table.new(
        title: title.green,
        headings: ["Option", "Value"],
        rows: rows.delete_if { |c| c.to_s.empty? }
      )
    end

    #####################################################
    # @!group The individual steps
    #####################################################

    # Builds the app and prepares the archive
    def build_app
      command = BuildCommandGenerator.generate
      print_command(command, "Generated Build Command")
      execute_command(command: command, print_all: true, error: proc do |output|
        ErrorHandler.handle_build_error(output)
      end)

      puts Terminal::Table.new(
        title: "Successfully generated archive".green,
        rows: [
          ["Archive", BuildCommandGenerator.archive_path]
        ]
      )
    end

    # Makes sure the archive is there and valid
    def verify_archive
      if Dir[BuildCommandGenerator.archive_path + "/*"].count == 0
        ErrorHandler.handle_empty_archive
      end
    end

    def package_app
      command = PackageCommandGenerator.generate
      print_command(command, "Generated Package Command")

      execute_command(command: command, print_all: false, error: proc do |output|
        ErrorHandler.handle_package_error(output)
      end)

      rows = []
      rows << ["ipa", PackageCommandGenerator.ipa_path]
      rows << ["dSYM", PackageCommandGenerator.dsym_path] if PackageCommandGenerator.dsym_path
      puts Terminal::Table.new(
        title: "Successfully exported binary".green,
        rows: rows
      )
    end

    # Moves over the binary and dsym file to the output directory
    def move_results
      require 'fileutils'
      FileUtils.mv(PackageCommandGenerator.ipa_path, Gym.config[:output_directory], force: true)
      FileUtils.mv(PackageCommandGenerator.dsym_path, Gym.config[:output_directory], force: true) if PackageCommandGenerator.dsym_path
    end

    #####################################################
    # @!group Actually executing the commands
    #####################################################

    def execute_command(command: nil, print_all: false, error: nil)
      command = command.join(" ")
      Helper.log.info command.yellow.strip

      output = []
      last_length = 0
      PTY.spawn(command) do |stdin, stdout, pid|
        stdin.each do |l|
          line = l.strip # strip so that \n gets removed
          output << line

          if print_all
            current_length = line.length
            spaces = [last_length - current_length, 0].max
            print (line + " " * spaces + "\r")
            last_length = current_length
          end
        end
        Process.wait(pid)
      end

      # Exit status for build command, should be 0 if build succeeded
      if $?.exitstatus != 0
        error.call(output)
      end
    end
  end
end
