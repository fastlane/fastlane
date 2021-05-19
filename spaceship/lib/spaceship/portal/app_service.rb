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
      AppAttest = AppService.new_service("APP_ATTEST")
      AppGroup = AppService.new_service("APP_GROUPS")
      ApplePay = AppService.new_service("APPLE_PAY")
      AssociatedDomains = AppService.new_service("ASSOCIATED_DOMAINS")
      AutoFillCredential = AppService.new_service("AUTOFILL_CREDENTIAL_PROVIDER")
      ClassKit = AppService.new_service("CLASSKIT")
      Cloud = AppService.new_service("ICLOUD", settings: {xcode6_compatible: "XCODE_6", xcode5_compatible: "XCODE_5"}, key: "ICLOUD_VERSION")
      CustomNetworkProtocol = AppService.new_service("NETWORK_CUSTOM_PROTOCOL")
      DataProtection = AppService.new_service("DATA_PROTECTION", settings: {complete: "COMPLETE_PROTECTION", unless_open: "PROTECTED_UNLESS_OPEN", until_first_auth: "PROTECTED_UNTIL_FIRST_USER_AUTH" }, key: "DATA_PROTECTION_PERMISSION_LEVEL")
      ExtendedVirtualAddressSpace = AppService.new_service("EXTENDED_VIRTUAL_ADDRESSING")
      FileProviderTestingMode = AppService.new_service("FILEPROVIDER_TESTINGMODE")
      Fonts = AppService.new_service("FONT_INSTALLATION")
      GameCenter = AppService.new_service("GAME_CENTER", settings: {ios: "GAME_CENTER_IOS", macos: "GAME_CENTER_MACOS"}, key: "GAME_CENTER_SETTING")
      HealthKit = AppService.new_service("HEALTHKIT")
      HLSInterstitialPreview = AppService.new_service("HLS_INTERSTITIAL_PREVIEW")
      HomeKit = AppService.new_service("HOMEKIT")
      Hotspot = AppService.new_service("HOT_SPOT")
      InAppPurchase = AppService.new_service("IN_APP_PURCHASE")
      InterAppAudio = AppService.new_service("INTER_APP_AUDIO")
      LowLatencyHLS = AppService.new_service("COREMEDIA_HLS_LOW_LATENCY")
      ManagedAssociatedDomains = AppService.new_service("MDM_MANAGED_ASSOCIATED_DOMAINS")
      Maps = AppService.new_service("MAPS")
      Multipath = AppService.new_service("MULTIPATH")
      NetworkExtension = AppService.new_service("NETWORK_EXTENSIONS")
      NFCTagReading = AppService.new_service("NFC_TAG_READING")
      PersonalVPN = AppService.new_service("PERSONAL_VPN")
      Passbook = AppService.new_service("pass")
      PushNotification = AppService.new_service("PUSH_NOTIFICATIONS")
      SignInWithApple = AppService.new_service("APPLE_ID_AUTH", settings: {on: "PRIMARY_APP_CONSENT"}, key: "APPLE_ID_AUTH_APP_CONSENT")
      SiriKit = AppService.new_service("SIRIKIT")
      SystemExtension = AppService.new_service("SYSTEM_EXTENSION_INSTALL")
      UserManagement = AppService.new_service("USER_MANAGEMENT")
      VPNConfiguration = AppService.new_service("V66P55NK2I")
      Wallet = AppService.new_service("WALLET")
      WirelessAccessory = AppService.new_service("WIRELESS_ACCESSORY_CONFIGURATION")

      #Additional Capabilities
      CarPlayAudioApp = AppService.new_service("CARPLAY_PLAYABLE_CONTENT")
      CarPlayMessagingApp = AppService.new_service("CARPLAY_MESSAGING")
      CarPlayNavigationApp = AppService.new_service("CARPLAY_NAVIGATION")
      CarPlayVoipCallingApp = AppService.new_service("CARPLAY_VOIP")
      CriticalAlerts = AppService.new_service("CRITICAL_ALERTS")
      HotspotHelper = AppService.new_service("HOTSPOT_HELPER_MANAGED")

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
