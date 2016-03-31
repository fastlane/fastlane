module Spaceship
  module Tunes
    # Represents the encryption export compliance information for an app
    class AppExportCompliance < TunesBase
      # @return
      attr_reader :id
      attr_reader :upload_date
      attr_reader :code_value
      attr_reader :platform
      attr_reader :status
      attr_reader :export_compliance_required
      attr_reader :uses_non_exempt_encryption_from_plist
      attr_reader :ccat_file
      attr_reader :builds
      attr_reader :store_versions

      attr_mapping({
        'id' => :id,
        'uploadDate' => :upload_date,
        'codeValue' => :code_value,
        'platform' => :platform,
        'status' => :status,
        'exportComplianceRequired' => :export_compliance_required,
        'usesNonExemptEncryptionFromPlist' => :uses_non_exempt_encryption_from_plist,
        'builds' => :builds,
        'storeVersions' => :store_versions
      })

      class << self
        # Create a new object based on a hash.
        # This is used to create a new object based on the server response.
        def factory(attrs)
          obj = self.new(attrs)
          return obj
        end
      end

      def setup
        ccat_file = self.raw_data['ccatFile']
        if ccat_file
          @ccat_file = Tunes::AppCcatFile.factory(ccat_file['value'])
        end
      end
    end
  end
end
