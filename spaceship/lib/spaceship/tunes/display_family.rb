require_relative "../module"

module Spaceship
  module Tunes
    class DisplayFamily
      # The display family name from the App Store Connect API that
      # is used to assign `Spaceship::Tunes::AppScreenshot` objects
      # to the correct display families via its `device_type` property.
      attr_accessor :name

      # The user friendly name of this defintion as seen in the Media
      # Manager in App Store Connect.
      attr_accessor :friendly_name

      # The user friendly category for this defintion (i.e iPhone,
      # Apple TV or Desktop).
      attr_accessor :friendly_category_name

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

      def self.for_name(name)
        all_families[name]
      end

      def self.all_families
        @all_families ||= JSON.parse(File.read(File.join(Spaceship::ROOT, "lib", "assets", "displayFamilies.json"))).map { |data| [data["name"].to_sym, DisplayFamily.new(data)] }.to_h
      end

      def initialize(data)
        @name = data["name"]
        @friendly_name = data["friendly_name"]
        @friendly_category_name = data["friendly_category_name"]
        @screenshot_resolutions = data["screenshot_resolutions"]
        @picture_type = data["picture_type"]
        @messages_picture_type = data["messages_picture_type"]
      end
    end
  end
end
