require 'commander'
require 'deliver/download_screenshots'

HighLine.track_eof = false

module Deliver
  class CommandsGenerator
    include Commander::Methods

    def self.start(def_command = nil)
      begin
        FastlaneCore::UpdateChecker.start_looking_for_update('deliver')
        Deliver::DependencyChecker.check_dependencies
        self.new.run(def_command)
      ensure
        FastlaneCore::UpdateChecker.show_update_status('deliver', Deliver::VERSION)
      end
    end

    def run(def_command = nil)
      def_command ||= :run
      program :version, Deliver::VERSION
      program :description, 'CLI for \'deliver\' - Upload screenshots, metadata and your app to the App Store using a single command'
      program :help, 'Author', 'Felix Krause <deliver@krausefx.com>'
      program :help, 'Website', 'https://fastlane.tools'
      program :help, 'GitHub', 'https://github.com/krausefx/deliver'
      program :help_formatter, :compact

      global_option '-f', '--force', 'Runs a deployment without verifying any information (PDF file). This can be used for build servers.'
      global_option '--beta', 'Upload a beta build to iTunes Connect. This uses the `beta_ipa` block.'
      global_option '--skip-deploy', 'Skips submission of the build on iTunes Connect. This will only upload the ipa and/or metadata.'

      always_trace!

      command :run do |c|
        c.syntax = 'deliver'
        c.description = 'Run a deploy process using the Deliverfile in the current folder'
        c.action do |args, options|
          run_deliver(options)
        end
      end

      command :upload_metadata do |c|
        c.syntax = 'deliver upload_metadata'
        c.description = "Uploads new app metadata only. No binary will be uploaded"
        c.action do |args, options|
          ENV["DELIVER_SKIP_BINARY"] = "1"
          run_deliver(options)
        end
      end

      def run_deliver(options)
        path = (Deliver::Helper.fastlane_enabled?? './fastlane' : '.')
        Dir.chdir(path) do # switch the context
          if File.exists?(deliver_path)
            # Everything looks alright, use the given Deliverfile
            options.default :beta => false, :skip_deploy => false
            Deliver::Deliverer.new(deliver_path, force: options.force, is_beta_ipa: options.beta, skip_deploy: options.skip_deploy)
          else
            Deliver::Helper.log.warn("No Deliverfile found at path '#{deliver_path}'.")
            if agree("Do you want to create a new Deliverfile at the current directory? (y/n)", true)
              Deliver::DeliverfileCreator.create(enclosed_directory)
            end
          end
        end
      end

      command :init do |c|
        c.syntax = 'deliver init'
        c.option '-u', '--username String', String, 'Your Apple ID'
        c.description = "Creates a new Deliverfile in the current directory"

        c.action do |args, options|
          set_username(options.username)

          path = (Deliver::Helper.fastlane_enabled?? './fastlane' : '.')
          Deliver::DeliverfileCreator.create(path)
        end
      end

      command :download_screenshots do |c|
        c.syntax = 'deliver download_screenshots'
        c.description = "Downloads all existing screenshots from iTunes Connect and stores them in the screenshots folder"
        c.option '-a', '--app_identifier String', String, 'The App Identifier (e.g. com.krausefx.app)'
        c.option '-u', '--username String', String, 'Your Apple ID'
        c.action do |args, options|
          set_username(options.username)

          app_identifier = options.app_identifier || CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier) || ask("Please enter the app's bundle identifier: ")
          app = Deliver::App.new(app_identifier: app_identifier)

          path = (Deliver::Helper.fastlane_enabled?? './fastlane' : '.')
          path = File.join(path, "deliver")

          Deliver::DownloadScreenshots.run(app, path)
        end
      end

      command :testflight do |c|
        c.syntax = 'deliver testflight'
        c.description = "Uploads a given ipa file to the new Apple TestFlight"
        c.option '-a', '--app_id String', String, 'The App ID (numeric, like 956814360)'
        c.option '-u', '--username String', String, 'Your Apple ID'

        c.action do |args, options|
          ipa_path = (args.first || determine_ipa) + '' # unfreeze the string

          set_username(options.username)

          Deliver::Testflight.upload!(ipa_path, options.app_id, options.skip_deploy)
        end
      end

      def set_username(username)
        user = username
        user ||= ENV["DELIVER_USERNAME"]
        user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)
        CredentialsManager::PasswordManager.shared_manager(user) if user
      end

      def determine_ipa
        return Dir['*.ipa'].first if Dir["*.ipa"].count == 1
        loop do
          path = ask("Path to IPA file to upload: ".green)
          return path if File.exists?(path)
        end
      end

      def deliver_path
        File.join(enclosed_directory, Deliver::Deliverfile::Deliverfile::FILE_NAME)
      end

      # The directoy in which the Deliverfile and metadata should be created
      def enclosed_directory
        "."
      end

      default_command def_command

      run!
    end
  end
end