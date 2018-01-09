require 'commander'

require_relative 'module'
require_relative 'runner'
require_relative 'options'

HighLine.track_eof = false

module Snapshot
  class CommandsGenerator
    include Commander::Methods

    def self.start
      self.new.run
    end

    def run
      program :name, 'snapshot'
      program :version, Fastlane::VERSION
      program :description, 'CLI for \'snapshot\' - Automate taking localized screenshots of your iOS app on every device'
      program :help, 'Author', 'Felix Krause <snapshot@krausefx.com>'
      program :help, 'Website', 'https://fastlane.tools'
      program :help, 'Documentation', 'https://docs.fastlane.tools/actions/snapshot/'
      program :help_formatter, :compact

      global_option('--verbose', 'Shows a more verbose output') { FastlaneCore::Globals.verbose = true }

      always_trace!

      command :run do |c|
        c.syntax = 'fastlane snapshot'
        c.description = 'Take new screenshots based on the Snapfile.'

        FastlaneCore::CommanderGenerator.new.generate(Snapshot::Options.available_options, command: c)

        c.action do |args, options|
          load_config(options)

          Snapshot::DependencyChecker.check_simulators
          Snapshot::Runner.new.work
        end
      end

      command :init do |c|
        c.syntax = 'fastlane snapshot init'
        c.description = "Creates a new Snapfile in the current directory"

        c.action do |args, options|
          require 'snapshot/setup'
          path = Snapshot::Helper.fastlane_enabled? ? FastlaneCore::FastlaneFolder.path : '.'
          is_swift_fastfile = args.include?("swift")
          Snapshot::Setup.create(path, is_swift_fastfile: is_swift_fastfile)
        end
      end

      command :update do |c|
        c.syntax = 'fastlane snapshot update'
        c.description = "Updates your SnapshotHelper.swift to the latest version"

        c.action do |args, options|
          require 'snapshot/update'
          Snapshot::Update.new.update
        end
      end

      command :reset_simulators do |c|
        c.syntax = 'fastlane snapshot reset_simulators'
        c.description = "This will remove all your existing simulators and re-create new ones"
        c.option('-i', '--ios_version String', String, 'The comma separated list of iOS Versions you want to use')
        c.option('--force', 'Disables confirmation prompts')

        c.action do |args, options|
          options.default(ios_version: Snapshot::LatestOsVersion.ios_version)
          versions = options.ios_version.split(',') if options.ios_version
          require 'snapshot/reset_simulators'

          Snapshot::ResetSimulators.clear_everything!(versions, options.force)
        end
      end

      command :clear_derived_data do |c|
        c.syntax = 'fastlane snapshot clear_derived_data -f path'
        c.description = "Clear the directory where build products and other derived data will go"

        FastlaneCore::CommanderGenerator.new.generate(Snapshot::Options.available_options, command: c)

        c.action do |args, options|
          load_config(options)
          derived_data_path = Snapshot.config[:derived_data_path]

          if !derived_data_path
            Snapshot::UI.user_error!("No derived_data_path")
          elsif !Dir.exist?(derived_data_path)
            Snapshot::UI.important("Path #{derived_data_path} does not exist")
          else
            FileUtils.rm_rf(derived_data_path)
            Snapshot::UI.success("Removed #{derived_data_path}")
          end
        end
      end

      default_command(:run)

      run!
    end

    private

    def load_config(options)
      o = options.__hash__.dup
      o.delete(:verbose)
      Snapshot.config = FastlaneCore::Configuration.create(Snapshot::Options.available_options, o)
    end
  end
end
