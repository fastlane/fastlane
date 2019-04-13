require_relative "../module"

module Spaceship
  module Tunes
    class DeviceMediaDefinition
      # The display family name from the App Store Connect API that
      # is used to assign `Spaceship::Tunes::AppScreenshot` objects
      # to the correct display families
      attr_accessor :device_type

      # The user friendly name of this defintion as seen in the Media
      # Manager in App Store Connect.
      attr_accessor :name

      # The user friendly category for this defintion (i.e iPhone,
      # Apple TV or Desktop).
      attr_accessor :category_name

      # An array of supported screen resolutions (in pixels) that are
      # supported for the associated device.
      #
      # Source: https://help.apple.com/app-store-connect/#/devd274dd925
      attr_accessor :screenshot_resolutions

      # An internal identifier for the same device definition used
      # in the DUClient.
      #
      # Source: You can find this by uploading an image in App Store
      # Connect using your browser and then look for the
      # X-Apple-Upload-Validation-RuleSets value in the uploads
      # request headers.
      attr_accessor :picture_type

      # Similar to `picture_type`, but for iMessage screenshots.
      attr_accessor :messages_picture_type

      # Identifies if the device definition supports iMessage screenshots.
      def messages_supported?
        true unless messages_picture_type.nil?
      end

      def self.for_device_type(device_type)
        all_definitions[device_type]
      end

      def self.all_definitions
        @all_definitions ||= JSON.parse(File.read(File.join(Spaceship::ROOT, "lib", "assets", "deviceMediaDefinitions.json"))).map { |data| [data["device_type"].to_sym, DeviceMediaDefinition.new(data)] }.to_h
      end

      def initialize(data)
        @device_type = data["device_type"]
        @name = data["name"]
        @category_name = data["category_name"]
        @screenshot_resolutions = data["screenshot_resolutions"]
        @picture_type = data["picture_type"]
        @messages_picture_type = data["messages_picture_type"]
      end
    end
  end
end
