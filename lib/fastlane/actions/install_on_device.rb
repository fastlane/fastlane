module Fastlane
  module Actions
    module SharedValues
    end
    class InstallOnDeviceAction < Action
      def self.run(params)
        unless Helper.test?
          raise "ios-deploy not installed, see https://github.com/phonegap/ios-deploy for instructions".red if `which ios-deploy`.length == 0
        end
        taxi_cmd = [
          "ios-deploy",
          params[:extra],
          "--bundle",
          params[:ipa]
        ]
        taxi_cmd << "--no-wifi" if params[:skip_wifi]
        taxi_cmd << ["--id", params[:device_id]] if params[:device_id]
        return taxi_cmd.join(" ") if Helper.test?
        Actions.sh(taxi_cmd.join(" "))
        Helper.log.info "Deployed #{params[:ipa]} to device!"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Installs an .ipa file on a connected iOS-device via usb or wifi"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :extra,
                                       short_option: "-X",
                                       env_name: "FL_IOD_EXTRA",
                                       description: "Extra Commandline arguments passed to ios-deploy",
                                       optional: true,
                                       is_string: true
                                      ),
          FastlaneCore::ConfigItem.new(key: :device_id,
                                       short_option: "-d",
                                       env_name: "FL_IOD_DEVICE_ID",
                                       description: "id of the device / if not set defaults to first found device",
                                       optional: true,
                                       is_string: true
                                      ),
          FastlaneCore::ConfigItem.new(key: :skip_wifi,
                                       short_option: "-w",
                                       env_name: "FL_IOD_WIFI",
                                       description: "Do not search for devices via WiFi",
                                       optional: true,
                                       is_string: false
                                      ),
          FastlaneCore::ConfigItem.new(key: :ipa,
                                       short_option: "-i",
                                       env_name: "FL_IOD_IPA",
                                       description: "The IPA file to put on the device",
                                       optional: true,
                                       is_string: true,
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] || Dir["*.ipa"].first,
                                       verify_block: proc do |value|
                                         unless Helper.test?
                                           raise "Could not find ipa file at path '#{value}'" unless File.exist? value
                                           raise "'#{value}' doesn't seem to be an ipa file" unless value.end_with? ".ipa"
                                         end
                                       end
                                      )
        ]
      end

      def self.authors
        ["hjanuschka"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
