require 'commander'

require 'fastlane_core/configuration/configuration'
require 'fastlane_core/ui/help_formatter'
require_relative 'module'
require_relative 'manager'
require_relative 'options'

HighLine.track_eof = false

module Gym
  class CommandsGenerator
    include Commander::Methods

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
      program :help, "Documentation", "https://docs.fastlane.tools/actions/gym/"
      program :help_formatter, FastlaneCore::HelpFormatter

      global_option("--verbose") { FastlaneCore::Globals.verbose = true }

      command :build do |c|
        c.syntax = "fastlane gym"
        c.description = "Build your iOS/macOS app"

        FastlaneCore::CommanderGenerator.new.generate(Gym::Options.available_options, command: c)

        c.action do |_args, options|
          config = FastlaneCore::Configuration.create(Gym::Options.available_options,
                                                      convert_options(options))
          Gym::Manager.new.work(config)
        end
      end

      command :init do |c|
        c.syntax = "fastlane gym init"
        c.description = "Creates a new Gymfile for you"
        c.action do |args, options|
          containing = FastlaneCore::Helper.fastlane_enabled_folder_path
          path = File.join(containing, Gym.gymfile_name)
          UI.user_error!("Gymfile already exists") if File.exist?(path)

          is_swift_fastfile = args.include?("swift")
          if is_swift_fastfile
            path = File.join(containing, Gym.gymfile_name + ".swift")
            UI.user_error!("Gymfile.swift already exists") if File.exist?(path)
          end

          if is_swift_fastfile
            template = File.read("#{Gym::ROOT}/lib/assets/GymfileTemplate.swift")
          else
            template = File.read("#{Gym::ROOT}/lib/assets/GymfileTemplate")
          end

          File.write(path, template)
          UI.success("Successfully created '#{path}'. Open the file using a code editor.")
        end
      end

      default_command(:build)

      run!
    end
  end
end
