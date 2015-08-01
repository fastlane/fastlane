require "commander"
require "attach/options"
require "fastlane_core"

HighLine.track_eof = false

module Attach
  class CommandsGenerator
    include Commander::Methods

    FastlaneCore::CommanderGenerator.new.generate(Attach::Options.available_options)

    # def self.start
    #   FastlaneCore::UpdateChecker.start_looking_for_update("attach")
    #   new.run
    # ensure
    #   FastlaneCore::UpdateChecker.show_update_status("attach", Attach::VERSION)
    # end
    def self.start
      new.run
    end

    def convert_options(options)
      o = options.__hash__.dup
      o.delete(:verbose)
      o
    end

    def run
      program :version, Attach::VERSION
      program :description, Attach::DESCRIPTION
      program :help, "Author", "Felix Krause <attach@krausefx.com>"
      program :help, "Website", "https://fastlane.tools"
      program :help, "GitHub", "https://github.com/fastlane/attach"
      program :help_formatter, :compact

      global_option("--verbose") { $verbose = true }

      always_trace!

      command :build do |c|
        c.syntax = "attach"
        c.description = "Just builds your app"
        c.action do |_args, options|
          config = FastlaneCore::Configuration.create(Attach::Options.available_options, convert_options(options))
          Attach::Manager.new.work(config)
        end
      end

      default_command :build

      run!
    end
  end
end
