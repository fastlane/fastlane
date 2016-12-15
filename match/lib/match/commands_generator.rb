require 'commander'
require 'fastlane/version'

HighLine.track_eof = false

module Match
  class CommandsGenerator
    include Commander::Methods
    UI = FastlaneCore::UI

    def self.start
      self.new.run
    end

    def run
      program :name, 'match'
      program :version, Fastlane::VERSION
      program :description, Match::DESCRIPTION
      program :help, 'Author', 'Felix Krause <match@krausefx.com>'
      program :help, 'Website', 'https://fastlane.tools'
      program :help, 'GitHub', 'https://github.com/fastlane/match'
      program :help_formatter, :compact

      global_option('--verbose') { $verbose = true }

      FastlaneCore::CommanderGenerator.new.generate(Match::Options.available_options)

      command :run do |c|
        c.syntax = 'match'
        c.description = Match::DESCRIPTION

        c.action do |args, options|
          if args.count > 0
            FastlaneCore::UI.user_error!("Please run `match [type]`, allowed values: development, adhoc or appstore")
          end

          params = FastlaneCore::Configuration.create(Match::Options.available_options, options.__hash__)
          params.load_configuration_file("Matchfile")
          Match::Runner.new.run(params)
        end
      end

      Match.environments.each do |type|
        command type do |c|
          c.syntax = "match #{type}"
          c.description = "Run match for a #{type} provisioning profile"

          c.action do |args, options|
            params = FastlaneCore::Configuration.create(Match::Options.available_options, options.__hash__)
            params.load_configuration_file("Matchfile") # this has to be done *before* overwriting the value
            params[:type] = type.to_s
            Match::Runner.new.run(params)
          end
        end
      end

      command :init do |c|
        c.syntax = 'match init'
        c.description = 'Create the Matchfile for you'
        c.action do |args, options|
          containing = (File.directory?("fastlane") ? 'fastlane' : '.')
          path = File.join(containing, "Matchfile")

          if File.exist?(path)
            FastlaneCore::UI.user_error!("You already got a Matchfile in this directory")
            return 0
          end

          Match::Setup.new.run(path)
        end
      end

      command :change_password do |c|
        c.syntax = 'match change_password'
        c.description = 'Re-encrypt all files with a different password'
        c.action do |args, options|
          params = FastlaneCore::Configuration.create(Match::Options.available_options, options.__hash__)
          params.load_configuration_file("Matchfile")

          Match::ChangePassword.update(params: params)
          UI.success "Successfully changed the password. Make sure to update the password on all your clients and servers"
        end
      end

      command :decrypt do |c|
        c.syntax = "match decrypt"
        c.description = "Decrypts the repository and keeps it on the filesystem"
        c.action do |args, options|
          params = FastlaneCore::Configuration.create(Match::Options.available_options, options.__hash__)
          params.load_configuration_file("Matchfile")
          decrypted_repo = Match::GitHelper.clone(params[:git_url], params[:shallow_clone], branch: params[:git_branch])
          UI.success "Repo is at: '#{decrypted_repo}'"
        end
      end
      command "nuke" do |c|
        # We have this empty command here, since otherwise the normal `match` command will be executed
        c.syntax = "match nuke"
        c.description = "Delete all certificates and provisioning profiles from the Apple Dev Portal"
        c.action do |args, options|
          FastlaneCore::UI.user_error!("Please run `match nuke [type], allowed values: distribution and development. For the 'adhoc' type, please use 'distribution' instead.")
        end
      end

      ["development", "distribution"].each do |type|
        command "nuke #{type}" do |c|
          c.syntax = "match nuke #{type}"
          c.description = "Delete all certificates and provisioning profiles from the Apple Dev Portal of the type #{type}"
          c.action do |args, options|
            params = FastlaneCore::Configuration.create(Match::Options.available_options, options.__hash__)
            params.load_configuration_file("Matchfile")
            Match::Nuke.new.run(params, type: type.to_s)
          end
        end
      end

      default_command :run

      run!
    end
  end
end
