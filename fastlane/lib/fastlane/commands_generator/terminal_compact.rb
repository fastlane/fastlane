module Fastlane
  class CommandsGenerator
    class TerminalCompact < ::Commander::HelpFormatter::TerminalCompact
      def template(name)
        if RUBY_VERSION < '2.6'
          ERB.new(File.read(File.join(File.dirname(__FILE__), "#{name}.erb")), nil, '-')
        else
          ERB.new(File.read(File.join(File.dirname(__FILE__), "#{name}.erb")), trim_mode: '-')
        end
      end
    end
  end
end
