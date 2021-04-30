require 'commander'

module FastlaneCore
  class HelpFormatter < ::Commander::HelpFormatter::TerminalCompact
    def template(name)
      if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.6')
        ERB.new(File.read(File.join(File.dirname(__FILE__), "#{name}.erb")), nil, '-')
      else
        ERB.new(File.read(File.join(File.dirname(__FILE__), "#{name}.erb")), trim_mode: '-')
      end
    end
  end
end
