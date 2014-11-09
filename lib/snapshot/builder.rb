module Snapshot
  class Builder
    BUILD_DIR = '/tmp/snapshot'


    def initialize

    end

    def build_app
      command = generate_build_command
      Helper.log.warn command.green

      all_lines = []

      PTY.spawn(command) do |stdin, stdout, pid|
        stdin.each do |line|
          parse_build_line(line) if line.length > 2
          all_lines << line
        end
      end

      if all_lines.join('\n').include?'** BUILD SUCCEEDED **'
        Helper.log.info "Build succeeded".green
        return true
      else
        raise "Looks like the build was not successfull."
      end
    end

    private
      def parse_build_line(line)
        Helper.log.debug line
        if line.include?"** BUILD FAILED **"
          raise line
        end
      end

      def generate_build_command
        scheme = SnapshotConfig.shared_instance.project_path.split('/').last.split('.').first # TODO

        [
          "xctool",
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