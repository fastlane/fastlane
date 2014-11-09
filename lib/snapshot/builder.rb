require 'snapshot/dependency_checker'

module Snapshot
  class Builder
    BUILD_DIR = '/tmp/snapshot'


    def initialize

    end

    def build_app
      raise "Could not find project. Please pass the path to your project using 'project_path'.".red unless SnapshotConfig.shared_instance.project_name
      command = generate_build_command

      Helper.log.info "Building project '#{SnapshotConfig.shared_instance.project_name}'... this might take some time...".green
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

      def generate_build_command
        scheme = SnapshotConfig.shared_instance.scheme

        build_command = (DependencyChecker.xctool_installed? ? 'xctool' : 'xcodebuild')
        [
          build_command,
          "-sdk iphonesimulator#{SnapshotConfig.shared_instance.ios_version}",
          "CONFIGURATION_BUILD_DIR='#{BUILD_DIR}/build'",
          "-workspace '#{SnapshotConfig.shared_instance.project_path}'",
          "-scheme '#{scheme}'",
          "-configuration Debug",
          "DSTROOT='#{BUILD_DIR}'",
          "OBJROOT='#{BUILD_DIR}'",
          "SYMROOT='#{BUILD_DIR}'",
          "ONLY_ACTIVE_ARCH=NO",
          "clean build"
        ].join(' ')
      end
  end
end