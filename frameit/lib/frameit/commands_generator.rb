require 'commander'
require 'fastlane/version'
require 'fastlane_core/ui/help_formatter'
require 'fastlane_core/globals'
require 'fastlane_core/configuration/configuration'

require_relative 'device_types'
require_relative 'runner'
require_relative 'options'
require_relative 'dependency_checker'
require_relative 'device'

HighLine.track_eof = false

module Frameit
  class CommandsGenerator
    include Commander::Methods

    def self.start
      Frameit::DependencyChecker.check_dependencies
      self.new.run
    end

    def run
      program :name, 'frameit'
      program :version, Fastlane::VERSION
      program :description, 'Quickly put your screenshots into the right device frames'
      program :help, 'Author', 'Felix Krause <frameit@krausefx.com>'
      program :help, 'Website', 'https://fastlane.tools'
      program :help, 'Documentation', 'https://docs.fastlane.tools/actions/frameit/'
      program :help_formatter, FastlaneCore::HelpFormatter

      global_option('--verbose') { FastlaneCore::Globals.verbose = true }
      global_option('--env STRING[,STRING2]', String, 'Add environment(s) to use with `dotenv`')

      default_command(:run)

      # default
      command :run do |c|
        c.syntax = 'fastlane frameit black'
        c.description = "Adds a black frame around all screenshots"

        FastlaneCore::CommanderGenerator.new.generate(Frameit::Options.available_options, command: c)

        c.action do |args, options|
          load_config(options)
          Frameit::Runner.new.run('.', nil)
        end
      end

      # iPhone available colors
      frame_colors = {
        silver: { syntax: 'fastlane frameit silver', description: "Adds a silver frame around all screenshots" },
        gold: { syntax: 'fastlane frameit gold', description: "Adds a gold frame around all screenshots" },
        rose_gold: { syntax: 'fastlane frameit rose_gold', description: "Adds a rose gold frame around all screenshots" },
        midnight: { syntax: 'fastlane frameit midnight', description: "Adds a midnight frame around all screenshots" },
        starlight: { syntax: 'fastlane frameit starlight', description: "Adds a starlight frame around all screenshots" },
        purple: { syntax: 'fastlane frameit purple', description: "Adds a purple frame around all screenshots" },
        blue: { syntax: 'fastlane frameit blue', description: "Adds a blue frame around all screenshots" },
        red: { syntax: 'fastlane frameit red', description: "Adds a red frame around all screenshots" },
      }

      frame_colors.each do |color, details|
        command color do |c|
          c.syntax = details[:syntax]
          c.description = details[:description]

          FastlaneCore::CommanderGenerator.new.generate(Frameit::Options.available_options, command: c)

          c.action do |args, options|
            load_config(options)
            Frameit::Runner.new.run('.', Frameit::Color.const_get(color.to_s.upcase))
          end
        end
      end

      command :android do |c|
        c.syntax = 'fastlane frameit android'
        c.description = "Adds Android frames around all screenshots"

        FastlaneCore::CommanderGenerator.new.generate(Frameit::Options.available_options, command: c)

        c.action do |args, options|
          load_config(options)
          Frameit::Runner.new.run('.', nil, Platform::ANDROID)
        end
      end

      command :ios do |c|
        c.syntax = 'fastlane frameit ios'
        c.description = "Adds iOS frames around all screenshots"

        FastlaneCore::CommanderGenerator.new.generate(Frameit::Options.available_options, command: c)

        c.action do |args, options|
          load_config(options)
          Frameit::Runner.new.run('.', nil, Platform::IOS)
        end
      end

      command :setup do |c|
        c.syntax = 'fastlane frameit setup'
        c.description = "Downloads and sets up the latest device frames"

        c.action do |args, options|
          Frameit::FrameDownloader.new.download_frames
        end
      end

      command :download_frames do |c|
        c.syntax = 'fastlane frameit download_frames'
        c.description = "Downloads and sets up the latest device frames"

        c.action do |args, options|
          Frameit::FrameDownloader.new.download_frames
        end
      end

      alias_command(:white, :silver)

      run!
    end

    private

    def load_config(options)
      o = options.__hash__.dup
      o.delete(:verbose)
      Frameit.config = FastlaneCore::Configuration.create(Frameit::Options.available_options, o)
    end
  end
end
