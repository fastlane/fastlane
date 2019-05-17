require_relative './model'
require 'spaceship/test_flight/build'
module Spaceship
  module ConnectAPI
    class Build
      include Spaceship::ConnectAPI::Model

      attr_accessor :version
      attr_accessor :uploaded_date
      attr_accessor :expiration_date
      attr_accessor :expired
      attr_accessor :min_os_version
      attr_accessor :icon_asset_token
      attr_accessor :processing_state
      attr_accessor :uses_non_exempt_encryption
      attr_accessor :qc_state

      attr_accessor :pre_release_version
      attr_accessor :app

      attr_mapping({
        "version" => "version",
        "uploadedDate" => "uploaded_date",
        "expirationDate" => "expiration_date",
        "expired" => "expired",
        "minOsVersion" => "min_os_version",
        "iconAssetToken" => "icon_asset_token",
        "processingState" => "processing_state",
        "usesNonExemptEncryption" => "uses_non_exempt_encryption",
        "qcState" => "qc_state",

        "preReleaseVersion" => "pre_release_version",
        "app" => "app"
      })

      def self.type
        return "builds"
      end

      #
      # Helpers
      #

      def app_version
        raise "No pre_release_version included" unless pre_release_version
        return pre_release_version.version
      end

      def app_id
        raise "No app included" unless app
        return app.id
      end

      def bundle_id
        raise "No app included" unless app
        return app.bundle_id
      end

      def processed?
        return processing_state == "VALID"
      end

      # This is here temporarily until the removal of Spaceship::TestFlight
      def to_testflight_build
        h = {
          'buildVersion' => version,
          'uploadDate' => uploaded_date,
          'externalState' => processed? ? Spaceship::TestFlight::Build::BUILD_STATES[:active] : Spaceship::TestFlight::Build::BUILD_STATES[:processing],
          'appAdamId' => app_id,
          'bundleId' => bundle_id,
          'trainVersion' => app_version
        }

        return Spaceship::TestFlight::Build.new(h)
      end

      #
      # API
      #

      def self.all(app_id: nil, version: nil, build_number: nil, includes: nil)
        resps = client.get_builds(
          filter: { app: app_id, "preReleaseVersion.version" => version, version: build_number },
          includes: includes,
          limit: 30
        ).all_pages
        return resps.map(&:models).flatten
      end
    end
  end
end
