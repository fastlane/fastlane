module Spaceship
  module Portal
    # Represents a single application service (its state to be more precise) on the Apple Dev Portal
    class AppService
      # @return (String) The identifier used by the Dev Portal to represent this service
      # @example
      #   "homeKit"
      attr_accessor :service_id

      # @return (Object) The current value for this service
      # @example
      #   false
      attr_accessor :value

      # @return (String) The service URI for this service
      # @example
      #    "account/ios/identifiers/updateService.action"
      attr_accessor :service_uri

      def initialize(service_id, value)
        @service_id = service_id
        @value = value

        if @service_id == "push"
          # Push notifications have a special URI
          @service_uri = "account/ios/identifiers/updatePushService.action"
        else
          # Default service URI
          @service_uri = "account/ios/identifiers/updateService.action"
        end
      end

      class << self
        def app_group
          self::AppGroup
        end

        def apple_pay
          self::ApplePay
        end

        def associated_domains
          self::AssociatedDomains
        end

        def data_protection
          self::DataProtection
        end

        def game_center
          self::GameCenter
        end

        def health_kit
          self::HealthKit
        end

        def home_kit
          self::HomeKit
        end

        def wireless_accessory
          self::WirelessAccessory
        end

        def icloud
          self::Cloud
        end

        def cloud_kit
          self::CloudKit
        end

        def in_app_purchase
          self::InAppPurchase
        end

        def inter_app_audio
          self::InterAppAudio
        end

        def passbook
          self::Passbook
        end

        def push_notification
          self::PushNotification
        end

        def siri_kit
          self::SiriKit
        end

        def vpn_configuration
          self::VPNConfiguration
        end
      end

      def ==(other)
        self.class == other.class &&
          self.service_id == other.service_id &&
          self.value == other.value &&
          self.service_uri == other.service_uri
      end

      #
      # Modules for "constants"
      #
      module AppGroup
        def self.off
          AppService.new("APG3427HIY", false)
        end

        def self.on
          AppService.new("APG3427HIY", true)
        end
      end

      module ApplePay
        def self.off
          AppService.new("OM633U5T5G", false)
        end

        def self.on
          AppService.new("OM633U5T5G", true)
        end
      end

      module AssociatedDomains
        def self.off
          AppService.new("SKC3T5S89Y", false)
        end

        def self.on
          AppService.new("SKC3T5S89Y", true)
        end
      end

      module DataProtection
        def self.off
          AppService.new("dataProtection", "")
        end

        def self.complete
          AppService.new("dataProtection", "complete")
        end

        def self.unless_open
          AppService.new("dataProtection", "unlessopen")
        end

        def self.until_first_auth
          AppService.new("dataProtection", "untilfirstauth")
        end
      end

      module GameCenter
        def self.off
          AppService.new("gameCenter", false)
        end

        def self.on
          AppService.new("gameCenter", true)
        end
      end

      module HealthKit
        def self.off
          AppService.new("HK421J6T7P", false)
        end

        def self.on
          AppService.new("HK421J6T7P", true)
        end
      end

      module HomeKit
        def self.off
          AppService.new("homeKit", false)
        end

        def self.on
          AppService.new("homeKit", true)
        end
      end

      module WirelessAccessory
        def self.off
          AppService.new("WC421J6T7P", false)
        end

        def self.on
          AppService.new("WC421J6T7P", true)
        end
      end

      module Cloud
        def self.off
          AppService.new("iCloud", false)
        end

        def self.on
          AppService.new("iCloud", true)
        end
      end

      module CloudKit
        def self.xcode5_compatible
          AppService.new("cloudKitVersion", 1)
        end

        def self.cloud_kit
          AppService.new("cloudKitVersion", 2)
        end
      end

      module InAppPurchase
        def self.off
          AppService.new("inAppPurchase", false)
        end

        def self.on
          AppService.new("inAppPurchase", true)
        end
      end

      module InterAppAudio
        def self.off
          AppService.new("IAD53UNK2F", false)
        end

        def self.on
          AppService.new("IAD53UNK2F", true)
        end
      end

      module Passbook
        def self.off
          AppService.new("pass", false)
        end

        def self.on
          AppService.new("pass", true)
        end
      end

      module PushNotification
        def self.off
          AppService.new("push", false)
        end

        def self.on
          AppService.new("push", true)
        end
      end

      module SiriKit
        def self.off
          AppService.new("SI015DKUHP", false)
        end

        def self.on
          AppService.new("SI015DKUHP", true)
        end
      end

      module VPNConfiguration
        def self.off
          AppService.new("V66P55NK2I", false)
        end

        def self.on
          AppService.new("V66P55NK2I", true)
        end
      end
    end
  end
end
