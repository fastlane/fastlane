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

      # @return (Hash) The current capability_settings hash, if applicable, for this service
      # @example
      #   {
      #      key: "DATA_PROTECTION_PERMISSION_LEVEL",
      #      options:
      #      [
      #        {
      #          key: "COMPLETE_PROTECTION"
      #        }
      #      ]
      #    }
      attr_accessor :capability_settings

      # @return (String) The current capability_settings value, if applicable, for this service
      # @example
      #   "COMPLETE_PROTECTION"
      attr_accessor :capability_settings_value

      # @return (String) The service URI for this service
      # @example
      #    "account/ios/identifiers/updateService.action"
      attr_accessor :service_uri

      def initialize(service_id, value: true, settings: nil, key: nil)
        @service_id = service_id
        @value = value
        @capability_settings_value = settings
        @capability_settings = build_compatibility_settings(settings, key)
      end

      def self.new_service(id, values: { on: true, off: false }, settings: nil, key: nil)
        m = Module.new
        values.each do |k, v|
          m.define_singleton_method(k) do
            AppService.new(id, value: v)
          end
        end
        if settings
          settings.each do |k, v|
            m.define_singleton_method(k) do
              AppService.new(id, settings: v, key:key)
            end
          end
        end
        return m
      end

      def build_compatibility_settings(settings, key)
        if settings.nil? || key.nil?
          return []
        end
        compatibility_settings = [{
          key: key,
          options: [
            {
              key: settings
            }
          ]
        }]
        return compatibility_settings
      end

      AccessWifi = AppService.new_service("ACCESS_WIFI_INFORMATION")
      AppGroup = AppService.new_service("APP_GROUPS")
      ApplePay = AppService.new_service("APPLE_PAY")
      AssociatedDomains = AppService.new_service("ASSOCIATED_DOMAINS")
      ClassKit = AppService.new_service("CLASSKIT")
      AutoFillCredential = AppService.new_service("AUTOFILL_CREDENTIAL_PROVIDER")
      DataProtection = AppService.new_service("DATA_PROTECTION", settings: {complete: "COMPLETE_PROTECTION", unless_open: "PROTECTED_UNLESS_OPEN", until_first_auth: "PROTECTED_UNTIL_FIRST_USER_AUTH" }, key: "DATA_PROTECTION_PERMISSION_LEVEL")
      GameCenter = AppService.new_service("GAME_CENTER")
      HealthKit = AppService.new_service("HEALTHKIT")
      HomeKit = AppService.new_service("HOMEKIT")
      Hotspot = AppService.new_service("HOT_SPOT")
      Cloud = AppService.new_service("ICLOUD")
      CloudKit = AppService.new_service("cloudKitVersion", values: { xcode5_compatible: 1, cloud_kit: 2 })
      InAppPurchase = AppService.new_service("IN_APP_PURCHASE")
      InterAppAudio = AppService.new_service("INTER_APP_AUDIO")
      Multipath = AppService.new_service("MULTIPATH")
      NetworkExtension = AppService.new_service("NETWORK_EXTENSIONS")
      NFCTagReading = AppService.new_service("NFC_TAG_READING")
      PersonalVPN = AppService.new_service("PERSONAL_VPN")
      Passbook = AppService.new_service("pass")
      PushNotification = AppService.new_service("PUSH_NOTIFICATIONS")
      SiriKit = AppService.new_service("SIRIKIT")
      VPNConfiguration = AppService.new_service("V66P55NK2I")
      Wallet = AppService.new_service("WALLET")
      WirelessAccessory = AppService.new_service("WIRELESS_ACCESSORY_CONFIGURATION")

      constants.each do |c|
        name = c.to_s
                .gsub(/([A-Z0-9]+)([A-Z][a-z])/, '\1_\2') # ABBRVString -> ABBRV_String
                .gsub(/([a-z0-9])([A-Z])/, '\1_\2')       # CamelCase -> Camel_Case
                .downcase
        self.class.send(:define_method, name) do
          AppService.const_get(c)
        end
      end

      def ==(other)
        self.class == other.class &&
          self.service_id == other.service_id &&
          self.value == other.value &&
          self.capability_settings_value == other.capability_settings_value
      end
    end
  end
end
