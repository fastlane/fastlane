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

      def self.new_service(id, values: { on: true, off: false })
        m = Module.new
        values.each do |k, v|
          m.define_singleton_method(k) do
            AppService.new(id, v)
          end
        end
        return m
      end

      AccessWiFi = AppService.new_service("AWEQ28MY3E")
      AppGroup = AppService.new_service("APG3427HIY")
      ApplePay = AppService.new_service("OM633U5T5G")
      AssociatedDomains = AppService.new_service("SKC3T5S89Y")
      ClassKit = AppService.new_service("PKTJAN2017")
      AutoFillCredential = AppService.new_service("CPEQ28MX4E")
      DataProtection = AppService.new_service("dataProtection", values: { off: "", complete: "complete", unless_open: "unlessopen", until_first_auth: "untilfirstauth" })
      GameCenter = AppService.new_service("gameCenter")
      HealthKit = AppService.new_service("HK421J6T7P")
      HomeKit = AppService.new_service("homeKit")
      Hotspot = AppService.new_service("HSC639VEI8")
      Cloud = AppService.new_service("iCloud")
      CloudKit = AppService.new_service("cloudKitVersion", values: { xcode5_compatible: 1, cloud_kit: 2 })
      InAppPurchase = AppService.new_service("inAppPurchase")
      InterAppAudio = AppService.new_service("IAD53UNK2F")
      Multipath = AppService.new_service("MP49FN762P")
      NetworkExtension = AppService.new_service("NWEXT04537")
      NFCTagReading = AppService.new_service("NFCTRMAY17")
      PersonalVPN = AppService.new_service("V66P55NK2I")
      Passbook = AppService.new_service("pass")
      PushNotification = AppService.new_service("push")
      SiriKit = AppService.new_service("SI015DKUHP")
      VPNConfiguration = AppService.new_service("V66P55NK2I")
      Wallet = AppService.new_service("pass")
      WirelessAccessory = AppService.new_service("WC421J6T7P")

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
          self.service_uri == other.service_uri
      end
    end
  end
end
