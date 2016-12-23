require 'commander'
require 'fastlane/version'

HighLine.track_eof = false

module Screengrab
  class CommandsGenerator
    include Commander::Methods

    def self.start
      self.new.run
    end

    def run
      program :name, 'screengrab'
      program :version, Fastlane::VERSION
      program :description, 'CLI for \'screengrab\' - Automate taking localized screenshots of your Android app on emulators or real devices'
      program :help, 'Authors', 'Andrea Falcone <afalcone@twitter.com>, Michael Furtak <mfurtak@twitter.com>'
      program :help, 'Website', 'https://fastlane.tools'
      program :help, 'GitHub', 'https://github.com/fastlane/screengrab'
      program :help_formatter, :compact

      global_option('--verbose', 'Shows a more verbose output') { $verbose = true }

      always_trace!

      FastlaneCore::CommanderGenerator.new.generate(Screengrab::Options.available_options)

      command :run do |c|
        c.syntax = 'screengrab'
        c.description = 'Take new screenshots based on the screengrabfile.'

        c.action do |args, options|
          o = options.__hash__.dup
          o.delete(:verbose)
          Screengrab.config = FastlaneCore::Configuration.create(Screengrab::Options.available_options, o)
          Screengrab.android_environment = Screengrab::AndroidEnvironment.new(Screengrab.config[:android_home],
                                                                              Screengrab.config[:build_tools_version])

          Screengrab::DependencyChecker.check(Screengrab.android_environment)
          Screengrab::Runner.new.run
        end
      end

      command :init do |c|
        c.syntax = 'screengrab init'
        c.description = "Creates a new Screengrabfile in the current directory"

        c.action do |args, options|
          require 'screengrab/setup'
          path = (Screengrab::Helper.fastlane_enabled? ? './fastlane' : '.')
          Screengrab::Setup.create(path)
        end
      end

      default_command :run

      run!
    end
  end
end
