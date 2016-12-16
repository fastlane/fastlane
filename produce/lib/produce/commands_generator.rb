require 'commander'
require 'fastlane/version'

HighLine.track_eof = false

module Produce
  class CommandsGenerator
    include Commander::Methods

    def self.start
      self.new.run
    end

    def run
      program :name, 'produce'
      program :version, Fastlane::VERSION
      program :description, 'CLI for \'produce\''
      program :help, 'Author', 'Felix Krause <produce@krausefx.com>'
      program :help, 'Website', 'https://fastlane.tools'
      program :help, 'GitHub', 'https://github.com/fastlane/produce'
      program :help_formatter, :compact

      global_option('--verbose') { $verbose = true }

      FastlaneCore::CommanderGenerator.new.generate(Produce::Options.available_options)

      command :create do |c|
        c.syntax = 'produce create'
        c.description = 'Creates a new app on iTunes Connect and the Apple Developer Portal'

        c.action do |args, options|
          Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, options.__hash__)

          puts Produce::Manager.start_producing
        end
      end

      command :enable_services do |c|
        c.syntax = 'produce enable_services -a APP_IDENTIFIER SERVICE1, SERVICE2, ...'
        c.description = 'Enable specific Application Services for a specific app on the Apple Developer Portal'
        c.example 'Enable HealthKit, HomeKit and Passbook', 'produce enable_services -a com.example.app --healthkit --homekit --passbook'

        c.option '--app-group', 'Enable App Groups'
        c.option '--apple-pay', 'Enable Apple Pay'
        c.option '--associated-domains', 'Enable Associated Domains'
        c.option '--data-protection STRING', String, 'Enable Data Protection, suitable values are "complete", "unlessopen" and "untilfirstauth"'
        c.option '--game-center', 'Enable Game Center'
        c.option '--healthkit', 'Enable HealthKit'
        c.option '--homekit', 'Enable HomeKit'
        c.option '--wireless-conf', 'Enable Wireless Accessory Configuration'
        c.option '--icloud STRING', String, 'Enable iCloud, suitable values are "legacy" and "cloudkit"'
        c.option '--in-app-purchase', 'Enable In-App Purchase'
        c.option '--inter-app-audio', 'Enable Inter-App-Audio'
        c.option '--passbook', 'Enable Passbook'
        c.option '--push-notification', 'Enable Push notification (only enables the service, does not configure certificates)'
        c.option '--sirikit', 'Enable SiriKit'
        c.option '--vpn-conf', 'Enable VPN Configuration'

        c.action do |args, options|
          # Filter the options so that we can still build the configuration
          allowed_keys = Produce::Options.available_options.collect(&:key)
          Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, options.__hash__.select { |key, value| allowed_keys.include? key })

          require 'produce/service'
          Produce::Service.enable(options, args)
        end
      end

      command :disable_services do |c|
        c.syntax = 'produce disable_services -a APP_IDENTIFIER SERVICE1, SERVICE2, ...'
        c.description = 'Disable specific Application Services for a specific app on the Apple Developer Portal'
        c.example 'Disable HealthKit', 'produce disable_services -a com.example.app --healthkit'

        c.option '--app-group', 'Disable App Groups'
        c.option '--apple-pay', 'Disable Apple Pay'
        c.option '--associated-domains', 'Disable Associated Domains'
        c.option '--data-protection', 'Disable Data Protection'
        c.option '--game-center', 'Disable Game Center'
        c.option '--healthkit', 'Disable HealthKit'
        c.option '--homekit', 'Disable HomeKit'
        c.option '--wireless-conf', 'Disable Wireless Accessory Configuration'
        c.option '--icloud', 'Disable iCloud'
        c.option '--in-app-purchase', 'Disable In-App Purchase'
        c.option '--inter-app-audio', 'Disable Inter-App-Audio'
        c.option '--passbook', 'Disable Passbook'
        c.option '--push-notification', 'Disable Push notifications'
        c.option '--sirikit', 'Disable SiriKit'
        c.option '--vpn-conf', 'Disable VPN Configuration'

        c.action do |args, options|
          # Filter the options so that we can still build the configuration
          allowed_keys = Produce::Options.available_options.collect(&:key)
          Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, options.__hash__.select { |key, value| allowed_keys.include? key })

          require 'produce/service'
          Produce::Service.disable(options, args)
        end
      end

      command :group do |c|
        c.syntax = 'produce group'
        c.description = 'Ensure that a specific App Group exists'
        c.example 'Create group', 'produce group -g group.example.app -n "Example App Group"'

        c.option '-n', '--group_name STRING', String, 'Name for the group that is created (PRODUCE_GROUP_NAME)'
        c.option '-g', '--group_identifier STRING', String, 'Group identifier for the group (PRODUCE_GROUP_IDENTIFIER)'

        c.action do |args, options|
          allowed_keys = Produce::Options.available_options.collect(&:key)
          Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, options.__hash__.select { |key, value| allowed_keys.include? key })

          require 'produce/group'
          Produce::Group.new.create(options, args)
        end
      end

      command :associate_group do |c|
        c.syntax = 'produce associate_group -a APP_IDENTIFIER GROUP_IDENTIFIER1, GROUP_IDENTIFIER2, ...'
        c.description = 'Associate with a group, which is create if needed or simply located otherwise'
        c.example 'Associate with group', 'produce associate-group -a com.example.app group.example.com'

        c.action do |args, options|
          Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, options.__hash__)

          require 'produce/group'
          Produce::Group.new.associate(options, args)
        end
      end

      default_command :create

      run!
    end
  end
end
