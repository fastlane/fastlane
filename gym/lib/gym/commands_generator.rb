require "commander"
require "fastlane_core"

HighLine.track_eof = false

module Gym
  class CommandsGenerator
    include Commander::Methods
    UI = FastlaneCore::UI

    FastlaneCore::CommanderGenerator.new.generate(Gym::Options.available_options)

    def self.start
      new.run
    end

    def convert_options(options)
      o = options.__hash__.dup
      o.delete(:verbose)
      o
    end

    def run
      program :name, 'gym'
      program :version, Fastlane::VERSION
      program :description, Gym::DESCRIPTION
      program :help, "Author", "Felix Krause <gym@krausefx.com>"
      program :help, "Website", "https://fastlane.tools"
      program :help, "GitHub", "https://github.com/fastlane/fastlane/tree/master/gym"
      program :help_formatter, :compact

      global_option("--verbose") { $verbose = true }

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
          containing = (File.directory?("fastlane") ? 'fastlane' : '.')
          path = File.join(containing, Gym.gymfile_name)
          UI.user_error! "Gymfile already exists" if File.exist?(path)
          template = File.read("#{Gym::ROOT}/lib/assets/GymfileTemplate")
          File.write(path, template)
          UI.success "Successfully created '#{path}'. Open the file using a code editor."
        end
      end

      default_command :build

      run!
    end
  end
end
