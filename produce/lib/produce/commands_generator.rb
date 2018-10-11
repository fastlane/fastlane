require 'commander'

require 'fastlane/version'
require 'fastlane_core/configuration/config_item'
require_relative 'module'
require_relative 'manager'
require_relative 'options'

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
      program :help, 'Documentation', 'https://docs.fastlane.tools/actions/produce/'
      program :help_formatter, :compact

      global_option('--verbose') { FastlaneCore::Globals.verbose = true }

      command :create do |c|
        c.syntax = 'fastlane produce create'
        c.description = 'Creates a new app on App Store Connect and the Apple Developer Portal'

        FastlaneCore::CommanderGenerator.new.generate(Produce::Options.available_options, command: c)

        c.action do |args, options|
          Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, options.__hash__)

          puts(Produce::Manager.start_producing)
        end
      end

      command :enable_services do |c|
        c.syntax = 'fastlane produce enable_services -a APP_IDENTIFIER SERVICE1, SERVICE2, ...'
        c.description = 'Enable specific Application Services for a specific app on the Apple Developer Portal'
        c.example('Enable HealthKit, HomeKit and Passbook', 'fastlane produce enable_services -a com.example.app --healthkit --homekit --passbook')

        c.option('--app-group', 'Enable App Groups')
        c.option('--apple-pay', 'Enable Apple Pay')
        c.option('--auto-fill-credential', 'Enable AutoFill Credential')
        c.option('--associated-domains', 'Enable Associated Domains')
        c.option('--data-protection STRING', String, 'Enable Data Protection, suitable values are "complete", "unlessopen" and "untilfirstauth"')
        c.option('--game-center', 'Enable Game Center')
        c.option('--healthkit', 'Enable HealthKit')
        c.option('--homekit', 'Enable HomeKit')
        c.option('--hotspot', 'Enable Hotspot')
        c.option('--icloud STRING', String, 'Enable iCloud, suitable values are "legacy" and "cloudkit"')
        c.option('--in-app-purchase', 'Enable In-App Purchase')
        c.option('--inter-app-audio', 'Enable Inter-App-Audio')
        c.option('--multipath', 'Enable Multipath')
        c.option('--network-extension', 'Enable Network Extensions')
        c.option('--nfc-tag-reading', 'Enable NFC Tag Reading')
        c.option('--personal-vpn', 'Enable Personal VPN')
        c.option('--passbook', 'Enable Passbook (deprecated)')
        c.option('--push-notification', 'Enable Push notification (only enables the service, does not configure certificates)')
        c.option('--sirikit', 'Enable SiriKit')
        c.option('--vpn-conf', 'Enable VPN Configuration (deprecated)')
        c.option('--wallet', 'Enable Wallet')
        c.option('--wireless-conf', 'Enable Wireless Accessory Configuration')

        FastlaneCore::CommanderGenerator.new.generate(Produce::Options.available_options, command: c)

        c.action do |args, options|
          # Filter the options so that we can still build the configuration
          allowed_keys = Produce::Options.available_options.collect(&:key)
          Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, options.__hash__.select { |key, value| allowed_keys.include?(key) })

          require 'produce/service'
          Produce::Service.enable(options, args)
        end
      end

      command :disable_services do |c|
        c.syntax = 'fastlane produce disable_services -a APP_IDENTIFIER SERVICE1, SERVICE2, ...'
        c.description = 'Disable specific Application Services for a specific app on the Apple Developer Portal'
        c.example('Disable HealthKit', 'fastlane produce disable_services -a com.example.app --healthkit')

        c.option('--app-group', 'Disable App Groups')
        c.option('--apple-pay', 'Disable Apple Pay')
        c.option('--auto-fill-credential', 'Disable AutoFill Credential')
        c.option('--associated-domains', 'Disable Associated Domains')
        c.option('--data-protection', 'Disable Data Protection')
        c.option('--game-center', 'Disable Game Center')
        c.option('--healthkit', 'Disable HealthKit')
        c.option('--homekit', 'Disable HomeKit')
        c.option('--hotspot', 'Disable Hotspot')
        c.option('--icloud', 'Disable iCloud')
        c.option('--in-app-purchase', 'Disable In-App Purchase')
        c.option('--inter-app-audio', 'Disable Inter-App-Audio')
        c.option('--multipath', 'Disable Multipath')
        c.option('--network-extension', 'Disable Network Extensions')
        c.option('--nfc-tag-reading', 'Disable NFC Tag Reading')
        c.option('--personal-vpn', 'Disable Personal VPN')
        c.option('--passbook', 'Disable Passbook (deprecated)')
        c.option('--push-notification', 'Disable Push notifications')
        c.option('--sirikit', 'Disable SiriKit')
        c.option('--vpn-conf', 'Disable VPN Configuration (deprecated)')
        c.option('--wallet', 'Disable Wallet')
        c.option('--wireless-conf', 'Disable Wireless Accessory Configuration')

        FastlaneCore::CommanderGenerator.new.generate(Produce::Options.available_options, command: c)

        c.action do |args, options|
          # Filter the options so that we can still build the configuration
          allowed_keys = Produce::Options.available_options.collect(&:key)
          Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, options.__hash__.select { |key, value| allowed_keys.include?(key) })

          require 'produce/service'
          Produce::Service.disable(options, args)
        end
      end

      command :group do |c|
        c.syntax = 'fastlane produce group'
        c.description = 'Ensure that a specific App Group exists'
        c.example('Create group', 'fastlane produce group -g group.example.app -n "Example App Group"')

        c.option('-n', '--group_name STRING', String, 'Name for the group that is created (PRODUCE_GROUP_NAME)')
        c.option('-g', '--group_identifier STRING', String, 'Group identifier for the group (PRODUCE_GROUP_IDENTIFIER)')

        FastlaneCore::CommanderGenerator.new.generate(Produce::Options.available_options, command: c)

        c.action do |args, options|
          allowed_keys = Produce::Options.available_options.collect(&:key)
          Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, options.__hash__.select { |key, value| allowed_keys.include?(key) })

          require 'produce/group'
          Produce::Group.new.create(options, args)
        end
      end

      command :associate_group do |c|
        c.syntax = 'fastlane produce associate_group -a APP_IDENTIFIER GROUP_IDENTIFIER1, GROUP_IDENTIFIER2, ...'
        c.description = 'Associate with a group, which is created if needed or simply located otherwise'
        c.example('Associate with group', 'fastlane produce associate-group -a com.example.app group.example.com')

        FastlaneCore::CommanderGenerator.new.generate(Produce::Options.available_options, command: c)

        c.action do |args, options|
          Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, options.__hash__)

          require 'produce/group'
          Produce::Group.new.associate(options, args)
        end
      end

      command :cloud_container do |c|
        c.syntax = 'fastlane produce cloud_container'
        c.description = 'Ensure that a specific iCloud Container exists'
        c.example('Create iCloud Container', 'fastlane produce cloud_container -g iCloud.com.example.app -n "Example iCloud Container"')

        c.option('-n', '--container_name STRING', String, 'Name for the iCloud Container that is created (PRODUCE_CLOUD_CONTAINER_NAME)')
        c.option('-g', '--container_identifier STRING', String, 'Identifier for the iCloud Container (PRODUCE_CLOUD_CONTAINER_IDENTIFIER')

        FastlaneCore::CommanderGenerator.new.generate(Produce::Options.available_options, command: c)

        c.action do |args, options|
          allowed_keys = Produce::Options.available_options.collect(&:key)
          Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, options.__hash__.select { |key, value| allowed_keys.include?(key) })

          require 'produce/cloud_container'
          Produce::CloudContainer.new.create(options, args)
        end
      end

      command :associate_cloud_container do |c|
        c.syntax = 'fastlane produce associate_cloud_container -a APP_IDENTIFIER CONTAINER_IDENTIFIER1, CONTAINER_IDENTIFIER2, ...'
        c.description = 'Associate with a iCloud Container, which is created if needed or simply located otherwise'
        c.example('Associate with iCloud Container', 'fastlane produce associate_cloud_container -a com.example.app iCloud.com.example.com')

        FastlaneCore::CommanderGenerator.new.generate(Produce::Options.available_options, command: c)

        c.action do |args, options|
          Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, options.__hash__)

          require 'produce/cloud_container'
          Produce::CloudContainer.new.associate(options, args)
        end
      end

      command :merchant do |c|
        c.syntax = 'fastlane produce merchant'
        c.description = 'Ensure that a specific Merchant exists'
        c.example('Create merchant', 'fastlane produce merchant -o merchant.com.example.production -r "Example Merchant Production"')

        c.option('-r', '--merchant_name STRING', String, 'Name for the merchant that is created (PRODUCE_MERCHANT_NAME)')
        c.option('-o', '--merchant_identifier STRING', String, 'Merchant identifier for the merchant (PRODUCE_MERCHANT_IDENTIFIER)')

        FastlaneCore::CommanderGenerator.new.generate(Produce::Options.available_options, command: c)

        c.action do |args, options|
          extra_options = [FastlaneCore::ConfigItem.new(key: :merchant_name, optional: true), FastlaneCore::ConfigItem.new(key: :merchant_identifier)]
          all_options = Produce::Options.available_options + extra_options
          allowed_keys = all_options.collect(&:key)

          Produce.config = FastlaneCore::Configuration.create(all_options, options.__hash__.select { |key, value| allowed_keys.include?(key) })

          require 'produce/merchant'
          Produce::Merchant.new.create(options, args)
        end
      end

      command :associate_merchant do |c|
        c.syntax = 'fastlane produce associate_merchant -a APP_IDENTIFIER MERCHANT_IDENTIFIER1, MERCHANT_IDENTIFIER2, ...'
        c.description = 'Associate with a merchant for use with Apple Pay. Apple Pay will be enabled for this app.'
        c.example('Associate with merchant', 'fastlane produce associate_merchant -a com.example.app merchant.com.example.production')

        FastlaneCore::CommanderGenerator.new.generate(Produce::Options.available_options, command: c)

        c.action do |args, options|
          Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, options.__hash__)

          require 'produce/merchant'
          Produce::Merchant.new.associate(options, args)
        end
      end

      default_command(:create)

      run!
    end
  end
end
