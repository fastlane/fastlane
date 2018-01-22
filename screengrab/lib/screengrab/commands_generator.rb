require 'commander'

require 'fastlane/version'
require 'fastlane_core/fastlane_folder'
require 'fastlane_core/configuration/configuration'
require_relative 'android_environment'
require_relative 'dependency_checker'
require_relative 'runner'
require_relative 'options'
require_relative 'module'

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
      program :help, 'Authors', 'Andrea Falcone <asfalcone@google.com>, Michael Furtak <mfurtak@google.com>'
      program :help, 'Website', 'https://fastlane.tools'
      program :help, 'Documentation', 'https://docs.fastlane.tools/actions/screengrab/'
      program :help_formatter, :compact

      global_option('--verbose', 'Shows a more verbose output') { FastlaneCore::Globals.verbose = true }

      always_trace!

      command :run do |c|
        c.syntax = 'fastlane screengrab'
        c.description = 'Take new screenshots based on the Screengrabfile.'

        FastlaneCore::CommanderGenerator.new.generate(Screengrab::Options.available_options, command: c)

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
        c.syntax = 'fastlane screengrab init'
        c.description = "Creates a new Screengrabfile in the current directory"

        c.action do |args, options|
          require 'screengrab/setup'
          path = Screengrab::Helper.fastlane_enabled? ? FastlaneCore::FastlaneFolder.path : '.'
          is_swift_fastfile = args.include?("swift")
          Screengrab::Setup.create(path, is_swift_fastfile: is_swift_fastfile)
        end
      end

      default_command(:run)

      run!
    end
  end
end
