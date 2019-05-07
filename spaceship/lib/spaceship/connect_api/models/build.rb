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
    end
  end
end
