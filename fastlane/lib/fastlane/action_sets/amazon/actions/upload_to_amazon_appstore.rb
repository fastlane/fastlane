module Fastlane
  module Actions
    module SharedValues
    end
  
    class UploadToAmazonAppstoreAction < Action
      require_relative '../helper.rb'

      def self.run(params)

        # Do logic here
        ActionSets::Amazon.do_something

        client = ActionSets::Amazon::Client.new
        client.do_stuff
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload to Amazon Appstore"
      end

      def self.details
        "Upload to Amazon Appstore"
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :apk,
          #                               env_name: "AMAZON_APK",
          #                               description: "Path to the APK file to upload",
          #                               code_gen_sensitive: true,
          #                               default_value: Dir["*.apk"].last || Dir[File.join("app", "build", "outputs", "apk", "app-Release.apk")].last,
          #                               default_value_dynamic: true,
          #                               optional: true,
          #                               verify_block: proc do |value|
          #                                 UI.user_error!("Could not find apk file at path '#{value}'") unless File.exist?(value)
          #                                 UI.user_error!("apk file is not an apk") unless value.end_with?('.apk')
          #                               end),
        ]
      end

      def self.output
      end

      def self.category
        :production
      end

      def self.example_code
        [
          'upload_to_amazon_appstore(
            apk: "path"
          )'
        ]
      end

      def self.authors
        ["kreeger", "joshdholtz"]
      end

      def self.is_supported?(platform)
        platform == :android
      end
    end
  end
end
  