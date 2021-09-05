module Fastlane
  module Actions
    module SharedValues
    end

    class AppetizeViewingUrlGeneratorAction < Action
      def self.run(params)
        link = "#{params[:base_url]}/#{params[:public_key]}"

        if params[:scale].nil? # sensible default values for scaling
          case params[:device].downcase.to_sym
          when :iphone6splus, :iphone6plus
            params[:scale] = "50"
          when :ipadair, :ipadair2
            params[:scale] = "50"
          else
            params[:scale] = "75"
          end
        end

        url_params = []
        url_params << "autoplay=true"
        url_params << "orientation=#{params[:orientation]}"
        url_params << "device=#{params[:device]}"
        url_params << "deviceColor=#{params[:color]}"
        url_params << "scale=#{params[:scale]}"
        url_params << "launchUrl=#{params[:launch_url]}" if params[:launch_url]
        url_params << "language=#{params[:language]}" if params[:language]
        url_params << "osVersion=#{params[:os_version]}" if params[:os_version]
        url_params << "params=#{CGI.escape(params[:params])}" if params[:params]
        url_params << "proxy=#{CGI.escape(params[:proxy])}" if params[:proxy]

        return link + "?" + url_params.join("&")
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Generate an URL for appetize simulator"
      end

      def self.details
        "Check out the [device_grid guide](https://github.com/fastlane/fastlane/blob/master/fastlane/lib/fastlane/actions/device_grid/README.md) for more information"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :public_key,
                                       env_name: "APPETIZE_PUBLICKEY",
                                       description: "Public key of the app you wish to update",
                                       sensitive: true,
                                       default_value: Actions.lane_context[SharedValues::APPETIZE_PUBLIC_KEY],
                                       default_value_dynamic: true,
                                       optional: false,
                                       verify_block: proc do |value|
                                         if value.start_with?("private_")
                                           UI.user_error!("You provided a private key to appetize, please provide the public key")
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :base_url,
                                       env_name: "APPETIZE_VIEWING_URL_GENERATOR_BASE",
                                       description: "Base URL of Appetize service",
                                       default_value: "https://appetize.io/embed",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :device,
                                       env_name: "APPETIZE_VIEWING_URL_GENERATOR_DEVICE",
                                       description: "Device type: iphone4s, iphone5s, iphone6, iphone6plus, ipadair, iphone6s, iphone6splus, ipadair2, nexus5, nexus7 or nexus9",
                                       default_value: "iphone5s"),
          FastlaneCore::ConfigItem.new(key: :scale,
                                       env_name: "APPETIZE_VIEWING_URL_GENERATOR_SCALE",
                                       description: "Scale of the simulator",
                                       optional: true,
                                       verify_block: proc do |value|
                                         available = ["25", "50", "75", "100"]
                                         UI.user_error!("Invalid scale, available: #{available.join(', ')}") unless available.include?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :orientation,
                                       env_name: "APPETIZE_VIEWING_URL_GENERATOR_ORIENTATION",
                                       description: "Device orientation",
                                       default_value: "portrait",
                                       verify_block: proc do |value|
                                         available = ["portrait", "landscape"]
                                         UI.user_error!("Invalid device, available: #{available.join(', ')}") unless available.include?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :language,
                                       env_name: "APPETIZE_VIEWING_URL_GENERATOR_LANGUAGE",
                                       description: "Device language in ISO 639-1 language code, e.g. 'de'",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :color,
                                       env_name: "APPETIZE_VIEWING_URL_GENERATOR_COLOR",
                                       description: "Color of the device",
                                       default_value: "black",
                                       verify_block: proc do |value|
                                         available = ["black", "white", "silver", "gray"]
                                         UI.user_error!("Invalid device color, available: #{available.join(', ')}") unless available.include?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :launch_url,
                                       env_name: "APPETIZE_VIEWING_URL_GENERATOR_LAUNCH_URL",
                                       description: "Specify a deep link to open when your app is launched",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :os_version,
                                       env_name: "APPETIZE_VIEWING_URL_GENERATOR_OS_VERSION",
                                       description: "The operating system version on which to run your app, e.g. 10.3, 8.0",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :params,
                                       env_name: "APPETIZE_VIEWING_URL_GENERATOR_PARAMS",
                                       description: "Specify params value to be passed to Appetize",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :proxy,
                                       env_name: "APPETIZE_VIEWING_URL_GENERATOR_PROXY",
                                       description: "Specify a HTTP proxy to be passed to Appetize",
                                       optional: true)
        ]
      end

      def self.category
        :misc
      end

      def self.return_value
        "The URL to preview the iPhone app"
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        [:ios].include?(platform)
      end
    end
  end
end
