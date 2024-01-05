require 'commander'

module FastlaneCore
  class HelpFormatter < ::Commander::HelpFormatter::TerminalCompact
    def template(name)
      # fastlane only customizes the global command help
      return super unless name == :help

      if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.6')
        ERB.new(File.read(File.join(File.dirname(__FILE__), "help.erb")), nil, '-')
      else
        ERB.new(File.read(File.join(File.dirname(__FILE__), "help.erb")), trim_mode: '-')
      end
    end
  end
end
