require_relative 'fastlane_exception'

module FastlaneCore
  class Interface
    class FastlaneShellError < FastlaneException
      attr_reader :show_github_issues

      def initialize(options = {})
        @show_github_issues = options[:show_github_issues].nil? ? false : options[:show_github_issues]
      end

      def prefix
        '[SHELL_ERROR]'
      end
    end
  end
end
