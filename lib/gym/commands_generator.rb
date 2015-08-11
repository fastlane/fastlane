require "commander"
require "fastlane_core"

HighLine.track_eof = false

module Gym
  class CommandsGenerator
    include Commander::Methods

    FastlaneCore::CommanderGenerator.new.generate(Gym::Options.available_options)

    def self.start
      FastlaneCore::UpdateChecker.start_looking_for_update("gym")
      new.run
    ensure
      FastlaneCore::UpdateChecker.show_update_status("gym", Gym::VERSION)
    end

    def convert_options(options)
      o = options.__hash__.dup
      o.delete(:verbose)
      o
    end

    def run
      program :version, Gym::VERSION
      program :description, Gym::DESCRIPTION
      program :help, "Author", "Felix Krause <gym@krausefx.com>"
      program :help, "Website", "https://fastlane.tools"
      program :help, "GitHub", "https://github.com/fastlane/gym"
      program :help_formatter, :compact

      global_option("--verbose") { $verbose = true }

      always_trace!

      command :build do |c|
        c.syntax = "gym"
        c.description = "Just builds your app"
        c.action do |_args, options|
          config = FastlaneCore::Configuration.create(Gym::Options.available_options,
                                                      convert_options(options))
          Gym::Manager.new.work(config)
        end
      end

      command :init do |c|
        c.syntax = "gym init"
        c.description = "Creates a new Gymfile for you"
        c.action do |_args, options|
          raise "Gymfile already exists" if File.exist?(Gym.gymfile_name)
          template = File.read("#{Helper.gem_path('gym')}/lib/assets/GymfileTemplate")
          File.write(Gym.gymfile_name, template)
          Helper.log.info "Successfully created '#{Gym.gymfile_name}'. Open the file using a code editor.".green
        end
      end

      default_command :build

      run!
    end
  end
end
