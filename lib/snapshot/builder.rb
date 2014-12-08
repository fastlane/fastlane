require 'snapshot/dependency_checker'

module Snapshot
  class Builder
    BUILD_DIR = '/tmp/snapshot'


    def initialize
      FileUtils.rm_rf(BUILD_DIR)
    end

    def build_app(clean: false)
      command = SnapshotConfig.shared_instance.build_command

      if not command
        # That's the default case, user did not provide a custom build_command
        raise "Could not find project. Please pass the path to your project using 'project_path'.".red unless SnapshotConfig.shared_instance.project_name
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
          rescue Exception => ex
            Helper.log.fatal all_lines.join("\n")
            raise ex
          end
        end
      end

      if all_lines.join('\n').include?'** BUILD SUCCEEDED **'
        Helper.log.info "BUILD SUCCEEDED".green
        return true
      else
        Helper.log.info(all_lines.join(' '))
        raise "Looks like the build was not successfull."
      end
    end

    private
      def parse_build_line(line)
        if line.include?"** BUILD FAILED **"
          raise line
        end
      end

      def generate_build_command(clean: false)
        scheme = SnapshotConfig.shared_instance.scheme

        proj_path = SnapshotConfig.shared_instance.project_path
        proj_key = 'project'
        proj_key = 'workspace' if proj_path.end_with?'.xcworkspace'

        build_command = (DependencyChecker.xctool_installed? ? 'xctool' : 'xcodebuild')

        actions = []
        actions << 'clean' if clean
        actions << "build"

        [
          build_command,
          "-sdk iphonesimulator",
          "CONFIGURATION_BUILD_DIR='#{BUILD_DIR}/build'",
          "-#{proj_key} '#{proj_path}'",
          "-scheme '#{scheme}'",
          "DSTROOT='#{BUILD_DIR}'",
          "OBJROOT='#{BUILD_DIR}'",
          "SYMROOT='#{BUILD_DIR}'",
          actions.join(' ')
        ].join(' ')
      end
  end
end