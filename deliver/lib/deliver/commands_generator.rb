require 'commander'
require 'deliver/download_screenshots'

HighLine.track_eof = false

module Deliver
  class CommandsGenerator
    include Commander::Methods

    def self.start
      FastlaneCore::UpdateChecker.start_looking_for_update('deliver')
      self.new.run
    ensure
      FastlaneCore::UpdateChecker.show_update_status('deliver', Deliver::VERSION)
    end

    def deliverfile_options(skip_verification: false)
      available_options = Deliver::Options.available_options
      return available_options unless skip_verification

      # These don't matter for downloading metadata, so verification can be skipped
      irrelevant_options_keys = [:ipa, :pkg, :app_rating_config_path]

      available_options.each do |opt|
        next unless irrelevant_options_keys.include?(opt.key)
        opt.verify_block = nil
        opt.conflicting_options = nil
      end

      return available_options
    end

    def run
      program :version, Deliver::VERSION
      program :description, Deliver::DESCRIPTION
      program :help, 'Author', 'Felix Krause <deliver@krausefx.com>'
      program :help, 'Website', 'https://fastlane.tools'
      program :help, 'GitHub', 'https://github.com/fastlane/fastlane/tree/master/deliver'
      program :help_formatter, :compact

      FastlaneCore::CommanderGenerator.new.generate(deliverfile_options)

      global_option('--verbose') { $verbose = true }

      always_trace!

      command :run do |c|
        c.syntax = 'deliver'
        c.description = 'Upload metadata and binary to iTunes Connect'
        c.action do |args, options|
          options = FastlaneCore::Configuration.create(deliverfile_options, options.__hash__)
          loaded = options.load_configuration_file("Deliverfile")
          loaded = true if options[:description] || options[:ipa] || options[:pkg] # do we have *anything* here?
          unless loaded
            if UI.confirm("No deliver configuration found in the current directory. Do you want to setup deliver?")
              require 'deliver/setup'
              Deliver::Runner.new(options) # to login...
              Deliver::Setup.new.run(options)
              return 0
            end
          end

          Deliver::Runner.new(options).run
        end
      end
      command :submit_build do |c|
        c.syntax = 'deliver submit_build'
        c.description = 'Submit a specific build-nr for review, use latest for the latest build'
        c.action do |args, options|
          options = FastlaneCore::Configuration.create(deliverfile_options, options.__hash__)
          options.load_configuration_file("Deliverfile")
          options[:submit_for_review] = true
          options[:build_number] = "latest" unless options[:build_number]
          Deliver::Runner.new(options).run
        end
      end
      command :init do |c|
        c.syntax = 'deliver init'
        c.description = 'Create the initial `deliver` configuration based on an existing app'
        c.action do |args, options|
          if File.exist?("Deliverfile") or File.exist?("fastlane/Deliverfile")
            UI.important("You already have a running deliver setup in this directory")
            return 0
          end

          require 'deliver/setup'
          options = FastlaneCore::Configuration.create(deliverfile_options, options.__hash__)
          Deliver::Runner.new(options) # to login...
          Deliver::Setup.new.run(options)
        end
      end

      command :generate_summary do |c|
        c.syntax = 'deliver generate_summary'
        c.description = 'Generate HTML Summary without uploading/downloading anything'
        c.action do |args, options|
          options = FastlaneCore::Configuration.create(deliverfile_options, options.__hash__)
          options.load_configuration_file("Deliverfile")
          Deliver::Runner.new(options)
          html_path = Deliver::GenerateSummary.new.run(options)
          UI.success "Successfully generated HTML report at '#{html_path}'"
          system("open '#{html_path}'") unless options[:force]
        end
      end

      command :download_screenshots do |c|
        c.syntax = 'deliver download_screenshots'
        c.description = "Downloads all existing screenshots from iTunes Connect and stores them in the screenshots folder"

        c.action do |args, options|
          options = FastlaneCore::Configuration.create(deliverfile_options(skip_verification: true), options.__hash__)
          options.load_configuration_file("Deliverfile")
          Deliver::Runner.new(options, skip_version: true) # to login...
          containing = FastlaneCore::Helper.fastlane_enabled? ? './fastlane' : '.'
          path = options[:screenshots_path] || File.join(containing, 'screenshots')
          Deliver::DownloadScreenshots.run(options, path)
        end
      end

      command :download_metadata do |c|
        c.syntax = 'deliver download_metadata'
        c.description = "Downloads existing metadata and stores it locally. This overwrites the local files."

        c.action do |args, options|
          options = FastlaneCore::Configuration.create(deliverfile_options(skip_verification: true), options.__hash__)
          options.load_configuration_file("Deliverfile")
          Deliver::Runner.new(options) # to login...
          containing = FastlaneCore::Helper.fastlane_enabled? ? './fastlane' : '.'
          path = options[:metadata_path] || File.join(containing, 'metadata')
          res = ENV["DELIVER_FORCE_OVERWRITE"]
          res ||= UI.confirm("Do you want to overwrite existing metadata on path '#{File.expand_path(path)}'?")
          return 0 unless res

          require 'deliver/setup'
          v = options[:app].latest_version
          if options[:app_version].to_s.length > 0
            v = options[:app].live_version if v.version != options[:app_version]
            if v.version != options[:app_version]
              raise "Neither the current nor live version match specified app_version \"#{options[:app_version]}\""
            end
          end

          Deliver::Setup.new.generate_metadata_files(v, path)
        end
      end

      default_command :run

      run!
    end
  end
end
