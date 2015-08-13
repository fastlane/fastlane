require 'pty'
require 'open3'

module Gym
  class Runner
    # @return (String) The path to the resulting ipa
    def run
      clear_old_files
      build_app
      verify_archive
      package_app
      swift_library_fix
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

    def clear_old_files
      if File.exist? PackageCommandGenerator.ipa_path
        File.delete(PackageCommandGenerator.ipa_path)
      end
    end

    # Builds the app and prepares the archive
    def build_app
      command = BuildCommandGenerator.generate
      print_command(command, "Generated Build Command") if $verbose
      execute_command(command: command, print_all: true, error: proc do |output|
        ErrorHandler.handle_build_error(output)
      end)

      Helper.log.info("Successfully stored the archive. You can find it in the Xcode Organizer.".green)
      Helper.log.info("Stored the archive in: ".green + BuildCommandGenerator.archive_path) if $verbose
    end

    # Makes sure the archive is there and valid
    def verify_archive
      if Dir[BuildCommandGenerator.archive_path + "/*"].count == 0
        ErrorHandler.handle_empty_archive
      end
    end

    def package_app
      command = PackageCommandGenerator.generate
      print_command(command, "Generated Package Command") if $verbose

      execute_command(command: command, print_all: false, error: proc do |output|
        ErrorHandler.handle_package_error(output)
      end)
    end

    # Determine whether it is a Swift project and, eventually, include all required libraries to copy from Xcode's toolchain directory.
    # Since there's no "xcodebuild" target to do just that, it is done post-build when exporting an archived build.
    def swift_library_fix
      require 'fileutils'

      ipa_swift_frameworks = Dir["#{PackageCommandGenerator.appfile_path}/Frameworks/libswift*"]

      unless ipa_swift_frameworks.empty?
        Dir.mktmpdir do |tmpdir|
          # Copy all necessary Swift libraries to a temporary "SwiftSupport" directory so that we can
          # easily add it to the .ipa later.
          swift_support = File.join(tmpdir, "SwiftSupport")

          Dir.mkdir(swift_support)

          developer_dir = `xcode-select --print-path`.strip
          ipa_swift_frameworks.each do |path|
            framework = File.basename(path)

            FileUtils.copy_file("#{developer_dir}/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/iphoneos/#{framework}", File.join(swift_support, framework))
          end

          # Add "SwiftSupport" to the .ipa archive
          Dir.chdir(tmpdir) do
            command_parts = ["zip --recurse-paths #{PackageCommandGenerator.ipa_path} SwiftSupport"]
            command_parts << "/dev/null" unless $verbose
            print_command(command_parts, "Fix Swift embedded code if needed") if $verbose

            execute_command(command: command_parts, print_all: false, error: proc do |output|
              ErrorHandler.handle_package_error(output)
            end)
          end
        end
      end
    end

    # Moves over the binary and dsym file to the output directory
    # @return (String) The path to the resulting ipa file
    def move_results
      require 'fileutils'

      FileUtils.mv(PackageCommandGenerator.ipa_path, Gym.config[:output_directory], force: true)

      if PackageCommandGenerator.dsym_path
        # Compress and move the dsym file
        containing_directory = File.expand_path("..", PackageCommandGenerator.dsym_path)
        file_name = File.basename(PackageCommandGenerator.dsym_path)

        output_path = File.expand_path(File.join(Gym.config[:output_directory], Gym.config[:output_name] + ".app.dSYM.zip"))
        command = "cd '#{containing_directory}' && zip -r '#{output_path}' '#{file_name}'"
        Helper.log.info command.yellow unless Gym.config[:silent]
        command_result = `#{command}`
        Helper.log.info command_result if $verbose

        puts "" # new line

        Helper.log.info "Successfully exported and compressed dSYM file: ".green
        Helper.log.info File.join(Gym.config[:output_directory], File.basename(PackageCommandGenerator.dsym_path))
      end

      ipa_path = File.join(Gym.config[:output_directory], File.basename(PackageCommandGenerator.ipa_path))

      Helper.log.info "Successfully exported and signed ipa file:".green
      Helper.log.info ipa_path
      ipa_path
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
      print_all = true if $verbose

      output = []
      command = command.join(" ")
      Helper.log.info command.yellow.strip unless Gym.config[:silent]

      puts "\n-----".cyan if print_all

      last_length = 0
      begin
        PTY.spawn(command) do |stdin, stdout, pid|
          stdin.each do |l|
            line = l.strip # strip so that \n gets removed
            output << line

            next unless print_all

            current_length = line.length
            spaces = [last_length - current_length, 0].max
            print((line + " " * spaces + "\r").cyan)
            last_length = current_length
          end
          Process.wait(pid)
          puts "-----\n".cyan if print_all
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
