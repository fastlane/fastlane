require 'pty'
require 'shellwords'

module Snapshot
  class Runner

    attr_accessor :errors

    def work
      self.errors = []

      Helper.log.info "Building and running project '#{SnapshotConfig.shared_instance.project_name}' - this might take some time...".green

      launch('de', 'iPhone5')

      raise errors.join('; ') if errors.count > 0
    end

    def launch(language, device_type)
      screenshots_path = "/tmp/snapshot/"
      FileUtils.rm_rf(screenshots_path)
      FileUtils.mkdir_p(screenshots_path)

      command = generate_test_command(language, device_type)

      Helper.log.debug command.yellow.strip
      PTY.spawn(command) do |stdin, stdout, pid|
        stdin.each do |line|
          puts line
        end
        Process.wait(pid)
      end
      # Exit status for build command, should be 0 if build succeeded
      errors << "Wrong exist status" unless $?.exitstatus == 0
    end

    def generate_test_command(language, device_type)
      scheme = SnapshotConfig.shared_instance.scheme

      proj_path = SnapshotConfig.shared_instance.project_path
      proj_key = 'project'
      proj_key = 'workspace' if proj_path.end_with?'.xcworkspace'

      pre_command = SnapshotConfig.shared_instance.custom_args || ENV["SNAPSHOT_CUSTOM_ARGS"] || ''
      custom_build_args = SnapshotConfig.shared_instance.custom_build_args || ENV["SNAPSHOT_CUSTOM_BUILD_ARGS"] || ''
      
      build_command = pre_command + ' xcodebuild'

      actions = []
      # actions << 'clean' if clean
      actions << 'test'

      pipe = "| xcpretty" # TODO

      [
        build_command,
        "-sdk iphonesimulator",
        "-#{proj_key} '#{proj_path}'",
        "-scheme '#{scheme}'",
        "-destination 'platform=iOS Simulator,name=iPad 2,OS=#{Snapshot.config[:ios_version}'",
        # "-AppleLanguages='(#{language})'",
        custom_build_args,
        actions.join(' '),
        pipe
      ].join(' ')
    end
  end
end
