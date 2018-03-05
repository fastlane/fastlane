require_relative 'fastlane_exception'

module FastlaneCore
  class Interface
    class FastlaneShellError < FastlaneException
      def prefix
        '[SHELL_ERROR]'
      end
    end
  end
end
