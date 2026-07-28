require_relative 'tunes_base'

module Spaceship
  module Tunes
    # Represents a submission for review of an App Store Connect Application
    # This class handles the submission of all review information and documents
    class AppSubmission < TunesBase
      # @return (Spaceship::Tunes::Application) A reference to the application
      #   this submission is for
      attr_accessor :application

      # @return (AppVersion) The version to use for this submission
      attr_accessor :version

      # @return (String) The platform of the device. This is usually "ios"
      # @example
      #   "appletvos"
      attr_accessor :platform

      # @return (Boolean) Submitted for Review
      attr_accessor :submitted_for_review

      # To pass from the user

      # @return (Boolean) Ad ID Info - Serves ads
      attr_accessor :add_id_info_serves_ads

      # @return (Boolean) Ad ID Info - Tracks actions
      attr_accessor :add_id_info_tracks_action

      # @return (Boolean) Ad ID Info - Tracks installs
      attr_accessor :add_id_info_tracks_install

      # @return (Boolean) Content Rights - Contains third party content
      attr_accessor :content_rights_contains_third_party_content

      # @return (Boolean) Content Rights - Has rights of content
      attr_accessor :content_rights_has_rights

      # @return (Boolean) Export Compliance - Available on French Store
      attr_accessor :export_compliance_available_on_french_store

      # @return (Not Yet Implemented) Export Compliance - CCAT File
      attr_accessor :export_compliance_ccat_file

      # @return (Boolean) Export Compliance - Contains proprietary cryptography
      attr_accessor :export_compliance_contains_proprietary_cryptography

      # @return (Boolean) Export Compliance - Contains third-party cryptography
      attr_accessor :export_compliance_contains_third_party_cryptography

      # @return (Boolean) Export Compliance - Is exempt
      attr_accessor :export_compliance_is_exempt

      # @return (Boolean) Export Compliance - Uses encryption
      attr_accessor :export_compliance_uses_encryption

      # @return (String) Export Compliance - App type
      attr_accessor :export_compliance_app_type

      # @return (Boolean) Export Compliance - Encryption Updated
      attr_accessor :export_compliance_encryption_updated

      # @return (Boolean) Export Compliance - Compliance Required
      attr_accessor :export_compliance_compliance_required

      # @return (String) Export Compliance - Platform
      attr_accessor :export_compliance_platform

      attr_mapping({
        # Ad ID Info Section
        'adIdInfo.servesAds.value' => :add_id_info_serves_ads,
        'adIdInfo.tracksAction.value' => :add_id_info_tracks_action,
        'adIdInfo.tracksInstall.value' => :add_id_info_tracks_install,

        # Content Rights Section
        'contentRights.containsThirdPartyContent.value' => :content_rights_contains_third_party_content,
        'contentRights.hasRights.value' => :content_rights_has_rights,

        # Export Compliance Section
        'exportCompliance.availableOnFrenchStore.value' => :export_compliance_available_on_french_store,
        'exportCompliance.ccatFile.value' => :export_compliance_ccat_file,
        'exportCompliance.containsProprietaryCryptography.value' => :export_compliance_contains_proprietary_cryptography,
        'exportCompliance.containsThirdPartyCryptography.value' => :export_compliance_contains_third_party_cryptography,
        'exportCompliance.isExempt.value' => :export_compliance_is_exempt,
        'exportCompliance.usesEncryption.value' => :export_compliance_uses_encryption,
        'exportCompliance.appType' => :export_compliance_app_type,
        'exportCompliance.encryptionUpdated.value' => :export_compliance_encryption_updated,
        'exportCompliance.exportComplianceRequired' => :export_compliance_compliance_required,
        'exportCompliance.platform' => :export_compliance_platform
      })

      class << self
        # Create a new object based on a hash.
        # This is used to create a new object based on the server response.
        def factory(attrs)
          # fill content rights section if iTC returns nil
          if attrs["contentRights"].nil?
            attrs["contentRights"] = {
              "containsThirdPartyContent" => {
                "value" => nil
              },
              "hasRights" => {
                "value" => nil
              }
            }
          end

          obj = self.new(attrs)
          return obj
        end

        # @param application (Spaceship::Tunes::Application) The app this submission is for
        def create(application, version, platform: nil)
          attrs = client.prepare_app_submissions(application.apple_id, application.edit_version(platform: platform).version_id)
          attrs[:application] = application
          attrs[:version] = version
          attrs[:platform] = platform

          return self.factory(attrs)
        end
      end

      # Save and complete the app submission
      def complete!
        raw_data_clone = raw_data.dup
        if self.content_rights_has_rights.nil? || self.content_rights_contains_third_party_content.nil?
          raw_data_clone.set(["contentRights"], nil)
        end
        raw_data_clone.delete(:version)
        raw_data_clone.delete(:application)

        client.send_app_submission(application.apple_id, application.edit_version(platform: platform).version_id, raw_data_clone)
        @submitted_for_review = true
      end

      def setup
        @submitted_for_review = false
      end
    end
  end
end
