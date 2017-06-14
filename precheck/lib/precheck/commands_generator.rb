require "commander"
require "fastlane_core"
require "fastlane/version"

HighLine.track_eof = false

module Precheck
  class CommandsGenerator
    include Commander::Methods

    def self.start
      new.run
    end

    def run
      program :name, 'precheck'
      program :version, Fastlane::VERSION
      program :description, Precheck::DESCRIPTION
      program :help, "Author", "Joshua Liebowitz <taquitos@gmail.com>, @taquitos"
      program :help, "Website", "https://fastlane.tools"
      program :help, "GitHub", "https://github.com/fastlane/fastlane/tree/master/precheck"
      program :help_formatter, :compact

      global_option("--verbose") { FastlaneCore::Globals.verbose = true }

      command :check_metadata do |c|
        c.syntax = "fastlane precheck"
        c.description = Precheck::DESCRIPTION

        FastlaneCore::CommanderGenerator.new.generate(Precheck::Options.available_options, command: c)

        c.action do |_args, options|
          Precheck.config = FastlaneCore::Configuration.create(Precheck::Options.available_options, options.__hash__)
          Precheck::Runner.new.run
        end
      end

      command :init do |c|
        c.syntax = "fastlane precheck init"
        c.description = "Creates a new Precheckfile for you"
        c.action do |_args, options|
          containing = FastlaneCore::Helper.fastlane_enabled_folder_path
          path = File.join(containing, Precheck.precheckfile_name)
          UI.user_error! "Precheckfile already exists" if File.exist?(path)
          template = File.read("#{Precheck::ROOT}/lib/assets/PrecheckfileTemplate")
          File.write(path, template)
          UI.success "Successfully created '#{path}'. Open the file using a code editor."
        end
      end

      default_command :check_metadata

      run!
    end
  end
end
