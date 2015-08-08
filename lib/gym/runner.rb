require 'pty'
require 'open3'

module Gym
  class Runner
    def run
      build_app
      verify_archive
      package_app
      move_results
    end

    private

    #####################################################
    # @!group Printing out things
    #####################################################

    # @param [Array] An array containing all the parts of the command
    def print_command(command, title)
      rows = command.map do |c|
        current = c.to_s.dup
        next unless current.length > 0

        if current.include? "-" and current.to_s.split(" '").count == 2
          # That's a default parameter, like `-project 'Name'`
          # We use " '" to not split by spaces within the value (e.g. path)
          current.split(" '")
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

      if PackageCommandGenerator.dsym_path
        # Compress and move the dsym file
        # FileUtils.mv(PackageCommandGenerator.dsym_path, Gym.config[:output_directory], force: true)

        containing_directory = File.expand_path("..", PackageCommandGenerator.dsym_path)
        file_name = File.basename(PackageCommandGenerator.dsym_path)

        output = File.expand_path(File.join(Gym.config[:output_directory], Gym.config[:output_name] + ".app.dSYM.zip"))
        puts `cd '#{containing_directory}' && zip -r '#{output}' '#{file_name}'`
      end
    end

    #####################################################
    # @!group Actually executing the commands
    #####################################################

    # @param command [String] The command to be executed
    # @param print_all [Boolean] Do we want to print out the command output while building?
    #   If set to false, nothing will be printed
    # @param error [Block] A block that's called if an error occurs
    # @return [String] All the output as string
    def execute_command(command: nil, print_all: false, error: nil)
      output = []

      command = command.join(" ")
      Helper.log.info command.yellow.strip

      last_length = 0
      begin
        PTY.spawn(command) do |stdin, stdout, pid|
          stdin.each do |l|
            line = l.strip # strip so that \n gets removed
            output << line

            next unless print_all

            current_length = line.length
            spaces = [last_length - current_length, 0].max
            print(line + " " * spaces + "\r")
            last_length = current_length
          end
          Process.wait(pid)
        end
      rescue => ex
        # This could happen when the environment is wrong:
        # > invalid byte sequence in US-ASCII (ArgumentError)
        output << ex.to_s
        o = output.join("\n")
        puts o
        error.call(o)
      end

      # Exit status for build command, should be 0 if build succeeded
      # Disabled Rubocop, since $CHILD_STATUS just is not the same
      if $?.exitstatus != 0 # rubocop:disable Style/SpecialGlobalVars
        o = output.join("\n")
        puts o # the user has the right to see the raw output
        error.call(o)
      end
    end
  end
end
