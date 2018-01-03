# rubocop:disable Style/FileName
# via https://github.com/fastlane/fastlane/pull/7202/files
module FastlaneCore
  class PTY
    def self.spawn(*cmd, &block)
      # Utopia - we have PTY
      if Gem::Specification.any? { |s| s.name == "pty" }
        require "pty"
        PTY.spawn(command) do |stdout, stdin, pid|
          block.call(stdin, stdout, pid)
        end
      else
        # Sucks - but lets try to handle it
        require "systemu"
        stdout = ''
        stderr = ''
        _status = systemu cmd, 'stdout' => stdout, 'stderr' => stderr
        block.call("", stdout, 0)
      end
    end
  end
end
