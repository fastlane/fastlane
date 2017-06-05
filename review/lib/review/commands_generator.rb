require "commander"
require "fastlane_core"
require "fastlane/version"

HighLine.track_eof = false

module Review
  class CommandsGenerator
    include Commander::Methods

    def self.start
      new.run
    end

    def run
      program :name, 'review'
      program :version, Fastlane::VERSION
      program :description, Review::DESCRIPTION
      program :help, "Author", "Joshua Liebowitz <taquitos@gmail.com>"
      program :help, "Website", "https://fastlane.tools"
      program :help, "GitHub", "https://github.com/fastlane/fastlane/tree/master/review"
      program :help_formatter, :compact

      global_option("--verbose") { FastlaneCore::Globals.verbose = true }

      command :check_metadata do |c|
        c.syntax = "fastlane review"
        c.description = Review::DESCRIPTION

        FastlaneCore::CommanderGenerator.new.generate(Review::Options.available_options, command: c)

        c.action do |_args, options|
          Review.config = FastlaneCore::Configuration.create(Review::Options.available_options, options.__hash__)
          Review::Runner.new.run
        end
      end

      default_command :check_metadata

      run!
    end
  end
end
