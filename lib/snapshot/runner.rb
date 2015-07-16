require 'pty'
require 'shellwords'

module Snapshot
  class Runner

    def work(clean: true)
      command = SnapshotConfig.shared_instance.build_command
      unless command
        # That's the default case, user did not provide a custom build_command
        unless SnapshotConfig.shared_instance.project_path
          raise "Could not find project. Please pass the path to your project using 'project_path'.".red
        end
        command = generate_test_command(clean: clean)
      end

      Helper.log.info "Building and running project '#{SnapshotConfig.shared_instance.project_name}' - this might take some time...".green
      Helper.log.debug command.yellow.strip

      all_lines = []

      PTY.spawn(command) do |stdin, stdout, pid|
        stdin.each do |line|
          all_lines << line
          begin
            parse_line(line) if line.length > 2 # \n
          rescue => ex
            Helper.log.fatal all_lines.join("\n")
            raise ex
          end
        end
        Process.wait(pid)
      end
      # Exit status for build command, should be 0 if build succeeded
      cmdstatus = $?.exitstatus
    end

    def parse_line(line)
      puts line
    end

    def generate_test_command(clean: true)
      scheme = SnapshotConfig.shared_instance.scheme

      proj_path = SnapshotConfig.shared_instance.project_path
      proj_key = 'project'
      proj_key = 'workspace' if proj_path.end_with?'.xcworkspace'

      pre_command = SnapshotConfig.shared_instance.custom_args || ENV["SNAPSHOT_CUSTOM_ARGS"] || ''
      custom_build_args = SnapshotConfig.shared_instance.custom_build_args || ENV["SNAPSHOT_CUSTOM_BUILD_ARGS"] || ''
      
      build_command = pre_command + ' xcodebuild'

      actions = []
      actions << 'clean' if clean
      actions << 'test'

      pipe = "| xcpretty" # TODO

      [
        build_command,
        "-sdk iphonesimulator",
        # "CONFIGURATION_BUILD_DIR='#{build_dir}/build'",
        "-#{proj_key} '#{proj_path}'",
        "-scheme '#{scheme}'",
        # "-derivedDataPath '#{build_dir}'",
        # "-destination 'platform=iOS Simulator,name=iPhone 6,OS=9.0'",
        # "DSTROOT='#{build_dir}'",
        # "OBJROOT='#{build_dir}'",
        # "SYMROOT='#{build_dir}'",
        custom_build_args,
        actions.join(' '),
        pipe
      ].join(' ')
    end


    private
    #   def build_dir
    #     @build_dir ||= SnapshotConfig.shared_instance.build_dir || '/tmp/snapshot'
    #   end
  end
end
