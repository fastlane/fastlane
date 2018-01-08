# rubocop:disable Style/FileName
# via https://github.com/fastlane/fastlane/pull/7202/files
module FastlaneCore
  class PTY
    def self.spawn(*cmd, &block)
      # We have PTY
      if Gem::Specification.any? { |s| s.name == "pty" }
        require "pty"
        PTY.spawn(command) do |stdout, stdin, pid|
          block.call(stdin, stdout, pid)
        end
      else
        # We don't - lets try to handle it
        Actions.verify_gem!('systemu')
        require "systemu"
        stdout = ''
        stderr = ''
        _status = systemu(cmd, 'stdout' => stdout, 'stderr' => stderr)
        block.call("", stdout, 0)
      end
    end
  end
end
