module Snapshot
  class Builder

    def initialize
      @build_dir = SnapshotConfig.shared_instance.build_dir || '/tmp/snapshot'
    end

    def build_app(clean: true)
      FileUtils.rm_rf(@build_dir) if clean

      command = SnapshotConfig.shared_instance.build_command

      if not command
        # That's the default case, user did not provide a custom build_command
        raise "Could not find project. Please pass the path to your project using 'project_path'.".red unless SnapshotConfig.shared_instance.project_path
        command = generate_build_command(clean: clean)
      end

      Helper.log.info "Building project '#{SnapshotConfig.shared_instance.project_name}' - this might take some time...".green
      Helper.log.debug command.yellow

      all_lines = []

      PTY.spawn(command) do |stdin, stdout, pid|
        stdin.each do |line|
          all_lines << line
          begin
            parse_build_line(line) if line.length > 2
          rescue => ex
            Helper.log.fatal all_lines.join("\n")
            raise ex
          end
        end
        Process.wait(pid)
      end
      # Exit status for build command, should be 0 if build succeeded
      cmdstatus = $?.exitstatus

      if cmdstatus == 0 || all_lines.join('\n').include?('** BUILD SUCCEEDED **')
        Helper.log.info "BUILD SUCCEEDED".green
        return true
      else
        Helper.log.info(all_lines.join(' '))
        raise "Looks like the build was not successful."
      end
    end

    private
      def parse_build_line(line)
        if line.include?"** BUILD FAILED **"
          raise line
        end
      end

      def generate_build_command(clean: true)
        scheme = SnapshotConfig.shared_instance.scheme

        proj_path = SnapshotConfig.shared_instance.project_path
        proj_key = 'project'
        proj_key = 'workspace' if proj_path.end_with?'.xcworkspace'

        pre_command = SnapshotConfig.shared_instance.custom_args || ENV["SNAPSHOT_CUSTOM_ARGS"] || ''
        custom_build_args = SnapshotConfig.shared_instance.custom_build_args || ENV["SNAPSHOT_CUSTOM_BUILD_ARGS"] || ''
        
        build_command = pre_command + ' ' + (DependencyChecker.xctool_installed? ? 'xctool' : 'xcodebuild')

        actions = []
        actions << 'clean' if clean
        actions << "build"

        [
          build_command,
          "-sdk iphonesimulator",
          "CONFIGURATION_BUILD_DIR='#{@build_dir}/build'",
          "-#{proj_key} '#{proj_path}'",
          "-scheme '#{scheme}'",
          "DSTROOT='#{@build_dir}'",
          "OBJROOT='#{@build_dir}'",
          "SYMROOT='#{@build_dir}'",
          custom_build_args,
          actions.join(' ')
        ].join(' ')
      end
  end
end