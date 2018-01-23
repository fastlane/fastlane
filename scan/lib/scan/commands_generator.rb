require 'commander'

require 'fastlane_core/configuration/configuration'
require_relative 'module'
require_relative 'manager'
require_relative 'options'

HighLine.track_eof = false

module Scan
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
      program :name, 'scan'
      program :version, Fastlane::VERSION
      program :description, Scan::DESCRIPTION
      program :help, "Author", "Felix Krause <scan@krausefx.com>"
      program :help, "Website", "https://fastlane.tools"
      program :help, "Documentation", "https://docs.fastlane.tools/actions/scan/"
      program :help_formatter, :compact

      global_option("--verbose") { FastlaneCore::Globals.verbose = true }

      command :tests do |c|
        c.syntax = "fastlane scan"
        c.description = Scan::DESCRIPTION

        FastlaneCore::CommanderGenerator.new.generate(Scan::Options.available_options, command: c)

        c.action do |_args, options|
          config = FastlaneCore::Configuration.create(Scan::Options.available_options,
                                                      convert_options(options))
          Scan::Manager.new.work(config)
        end
      end

      command :init do |c|
        c.syntax = "fastlane scan init"
        c.description = "Creates a new Scanfile for you"
        c.action do |args, options|
          containing = FastlaneCore::Helper.fastlane_enabled_folder_path
          path = File.join(containing, Scan.scanfile_name)
          UI.user_error!("Scanfile already exists").yellow if File.exist?(path)

          is_swift_fastfile = args.include?("swift")
          if is_swift_fastfile
            path = File.join(containing, Scan.scanfile_name + ".swift")
            UI.user_error!("Scanfile.swift already exists") if File.exist?(path)
          end

          if is_swift_fastfile
            template = File.read("#{Scan::ROOT}/lib/assets/ScanfileTemplate.swift")
          else
            template = File.read("#{Scan::ROOT}/lib/assets/ScanfileTemplate")
          end

          File.write(path, template)
          UI.success("Successfully created '#{path}'. Open the file using a code editor.")
        end
      end

      default_command(:tests)

      run!
    end
  end
end
