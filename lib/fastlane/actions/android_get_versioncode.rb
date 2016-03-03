module Fastlane
  module Actions
    module SharedValues
      ANDROID_VERSION_CODE = :ANDROID_VERSION_CODE
    end

    class AndroidGetVersioncodeAction < Action
      require 'supply'
      require 'supply/client'

      def self.run(params)
        Supply.config = params

        client.begin_edit(package_name: Supply.config[:package_name])
        current_code = client.apks_version_codes.max
        client.abort_current_edit

        Actions.lane_context[SharedValues::ANDROID_VERSION_CODE] = current_code

        current_code
      end

      def self.description
        'Gets the current versionCode of the app'
      end

      def self.details
        'Fetches the current versionCode from Google Play'
      end

      def self.available_options
        # I need all the options from supply in order to construct
        # the client based on it's "default" values
        Supply::Options.available_options
      end

      def self.output
        [
          ['ANDROID_VERSION_CODE', 'The current version code']
        ]
      end

      def self.return_value
        "The latest version code, as set in Google Play"
      end

      def self.authors
        ['aguenther']
      end

      def self.is_supported?(platform)
        platform == :android
      end

      def self.client
        @client ||= Supply::Client.make_from_config
      end
      private_class_method :client
    end
  end
end
