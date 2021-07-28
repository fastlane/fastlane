require 'commander'

require 'fastlane/version'
require 'fastlane_core/ui/help_formatter'
require 'fastlane_core/configuration/config_item'
require 'fastlane_core/print_table'
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
      program :help_formatter, FastlaneCore::HelpFormatter

      global_option('--verbose') { FastlaneCore::Globals.verbose = true }
      global_option('--env STRING[,STRING2]', String, 'Add environment(s) to use with `dotenv`')

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

        c.option('--access-wifi', 'Enable Access Wifi')
        c.option('--app-attest', 'Enable App Attest')
        c.option('--app-group', 'Enable App Group')
        c.option('--apple-pay', 'Enable Apple Pay')
        c.option('--associated-domains', 'Enable Associated Domains')
        c.option('--auto-fill-credential', 'Enable Auto Fill Credential')
        c.option('--class-kit', 'Enable Class Kit')
        c.option('--icloud STRING', String, 'Enable iCloud, suitable values are "xcode5_compatible" and "xcode6_compatible"')
        c.option('--custom-network-protocol', 'Enable Custom Network Protocol')
        c.option('--data-protection STRING', String, 'Enable Data Protection, suitable values are "complete", "unlessopen" and "untilfirstauth"')
        c.option('--family-controls', 'Enable Family Controls')
        c.option('--file-provider-testing-mode', 'Enable File Provider Testing Mode')
        c.option('--fonts', 'Enable Fonts')
        c.option('--extended-virtual-address-space', 'Enable Extended Virtual Address Space')
        c.option('--game-center STRING', String, 'Enable Game Center, suitable values are "ios" and "macos"')
        c.option('--health-kit', 'Enable Health Kit')
        c.option('--hls-interstitial-preview', 'Enable Hls Interstitial Preview')
        c.option('--home-kit', 'Enable Home Kit')
        c.option('--hotspot', 'Enable Hotspot')
        c.option('--in-app-purchase', 'Enable In App Purchase')
        c.option('--inter-app-audio', 'Enable Inter App Audio')
        c.option('--low-latency-hls', 'Enable Low Latency Hls')
        c.option('--managed-associated-domains', 'Enable Managed Associated Domains')
        c.option('--maps', 'Enable Maps')
        c.option('--multipath', 'Enable Multipath')
        c.option('--network-extension', 'Enable Network Extension')
        c.option('--nfc-tag-reading', 'Enable NFC Tag Reading')
        c.option('--personal-vpn', 'Enable Personal VPN')
        c.option('--passbook', 'Enable Passbook (deprecated)')
        c.option('--push-notification', 'Enable Push Notification')
        c.option('--sign-in-with-apple', 'Enable Sign In With Apple')
        c.option('--siri-kit', 'Enable Siri Kit')
        c.option('--system-extension', 'Enable System Extension')
        c.option('--user-management', 'Enable User Management')
        c.option('--vpn-configuration', 'Enable Vpn Configuration (deprecated)')
        c.option('--wallet', 'Enable Wallet')
        c.option('--wireless-accessory', 'Enable Wireless Accessory')
        c.option('--car-play-audio-app', 'Enable Car Play Audio App')
        c.option('--car-play-messaging-app', 'Enable Car Play Messaging App')
        c.option('--car-play-navigation-app', 'Enable Car Play Navigation App')
        c.option('--car-play-voip-calling-app', 'Enable Car Play Voip Calling App')
        c.option('--critical-alerts', 'Enable Critical Alerts')
        c.option('--hotspot-helper', 'Enable Hotspot Helper')
        c.option('--driver-kit', 'Enable DriverKit')
        c.option('--driver-kit-endpoint-security', 'Enable DriverKit Endpoint Security')
        c.option('--driver-kit-family-hid-device', 'Enable DriverKit Family HID Device')
        c.option('--driver-kit-family-networking', 'Enable DriverKit Family Networking')
        c.option('--driver-kit-family-serial', 'Enable DriverKit Family Serial')
        c.option('--driver-kit-hid-event-service', 'Enable DriverKit HID EventService')
        c.option('--driver-kit-transport-hid', 'Enable DriverKit Transport HID')
        c.option('--multitasking-camera-access', 'Enable Multitasking Camera Access')
        c.option('--sf-universal-link-api', 'Enable SFUniversalLink API')
        c.option('--vp9-decoder', 'Enable VP9 Decoder')
        c.option('--music-kit', 'Enable MusicKit')
        c.option('--shazam-kit', 'Enable ShazamKit')
        c.option('--communication-notifications', 'Enable Communication Notifications')
        c.option('--group-activities', 'Enable Group Activities')
        c.option('--health-kit-estimate-recalibration', 'Enable HealthKit Estimate Recalibration')
        c.option('--time-sensitive-notifications', 'Enable Time Sensitive Notifications')

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

        c.option('--access-wifi', 'Disable Access Wifi')
        c.option('--app-attest', 'Disable App Attest')
        c.option('--app-group', 'Disable App Group')
        c.option('--apple-pay', 'Disable Apple Pay')
        c.option('--associated-domains', 'Disable Associated Domains')
        c.option('--auto-fill-credential', 'Disable Auto Fill Credential')
        c.option('--class-kit', 'Disable Class Kit')
        c.option('--icloud', 'Disable iCloud')
        c.option('--custom-network-protocol', 'Disable Custom Network Protocol')
        c.option('--data-protection', 'Disable Data Protection')
        c.option('--extended-virtual-address-space', 'Disable Extended Virtual Address Space')
        c.option('--family-controls', 'Disable Family Controls')
        c.option('--file-provider-testing-mode', 'Disable File Provider Testing Mode')
        c.option('--fonts', 'Disable Fonts')
        c.option('--game-center', 'Disable Game Center')
        c.option('--health-kit', 'Disable Health Kit')
        c.option('--hls-interstitial-preview', 'Disable Hls Interstitial Preview')
        c.option('--home-kit', 'Disable Home Kit')
        c.option('--hotspot', 'Disable Hotspot')
        c.option('--in-app-purchase', 'Disable In App Purchase')
        c.option('--inter-app-audio', 'Disable Inter App Audio')
        c.option('--low-latency-hls', 'Disable Low Latency Hls')
        c.option('--managed-associated-domains', 'Disable Managed Associated Domains')
        c.option('--maps', 'Disable Maps')
        c.option('--multipath', 'Disable Multipath')
        c.option('--network-extension', 'Disable Network Extension')
        c.option('--nfc-tag-reading', 'Disable NFC Tag Reading')
        c.option('--personal-vpn', 'Disable Personal VPN')
        c.option('--passbook', 'Disable Passbook (deprecated)')
        c.option('--push-notification', 'Disable Push Notification')
        c.option('--sign-in-with-apple', 'Disable Sign In With Apple')
        c.option('--siri-kit', 'Disable Siri Kit')
        c.option('--system-extension', 'Disable System Extension')
        c.option('--user-management', 'Disable User Management')
        c.option('--vpn-configuration', 'Disable Vpn Configuration (deprecated)')
        c.option('--wallet', 'Disable Wallet')
        c.option('--wireless-accessory', 'Disable Wireless Accessory')
        c.option('--car-play-audio-app', 'Disable Car Play Audio App')
        c.option('--car-play-messaging-app', 'Disable Car Play Messaging App')
        c.option('--car-play-navigation-app', 'Disable Car Play Navigation App')
        c.option('--car-play-voip-calling-app', 'Disable Car Play Voip Calling App')
        c.option('--critical-alerts', 'Disable Critical Alerts')
        c.option('--hotspot-helper', 'Disable Hotspot Helper')
        c.option('--driver-kit', 'Disable DriverKit')
        c.option('--driver-kit-endpoint-security', 'Disable DriverKit Endpoint Security')
        c.option('--driver-kit-family-hid-device', 'Disable DriverKit Family HID Device')
        c.option('--driver-kit-family-networking', 'Disable DriverKit Family Networking')
        c.option('--driver-kit-family-serial', 'Disable DriverKit Family Serial')
        c.option('--driver-kit-hid-event-service', 'Disable DriverKit HID EventService')
        c.option('--driver-kit-transport-hid', 'Disable DriverKit Transport HID')
        c.option('--multitasking-camera-access', 'Disable Multitasking Camera Access')
        c.option('--sf-universal-link-api', 'Disable SFUniversalLink API')
        c.option('--vp9-decoder', 'Disable VP9 Decoder')
        c.option('--music-kit', 'Disable MusicKit')
        c.option('--shazam-kit', 'Disable ShazamKit')
        c.option('--communication-notifications', 'Disable Communication Notifications')
        c.option('--group-activities', 'Disable Group Activities')
        c.option('--health-kit-estimate-recalibration', 'Disable HealthKit Estimate Recalibration')
        c.option('--time-sensitive-notifications', 'Disable Time Sensitive Notifications')

        FastlaneCore::CommanderGenerator.new.generate(Produce::Options.available_options, command: c)

        c.action do |args, options|
          # Filter the options so that we can still build the configuration
          allowed_keys = Produce::Options.available_options.collect(&:key)
          Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, options.__hash__.select { |key, value| allowed_keys.include?(key) })

          require 'produce/service'
          Produce::Service.disable(options, args)
        end
      end

      command :available_services do |c|
        c.syntax = 'fastlane produce available_services -a APP_IDENTIFIER'
        c.description = 'Displays a list of allowed Application Services for a specific app.'
        c.example('Check Available Services', 'fastlane produce available_services -a com.example.app')

        FastlaneCore::CommanderGenerator.new.generate(Produce::Options.available_options, command: c)

        c.action do |args, options|
          # Filter the options so that we can still build the configuration
          allowed_keys = Produce::Options.available_options.collect(&:key)
          Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, options.__hash__.select { |key, value| allowed_keys.include?(key) })

          require 'produce/service'
          require 'terminal-table'

          services = Produce::Service.available_services(options, args)
          rows = services.map { |capabilities| [capabilities.name, capabilities.id, capabilities.description] }
          table = Terminal::Table.new(
            title: "Available Services",
            headings: ['Name', 'ID', 'Description'],
            rows: FastlaneCore::PrintTable.transform_output(rows),
            style: { all_separators: true }
          )
          puts(table)
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
