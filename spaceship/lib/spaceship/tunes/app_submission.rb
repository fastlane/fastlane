require_relative 'tunes_base'

module Spaceship
  module Tunes
    # Represents a submission for review of an iTunes Connect Application
    # This class handles the submission of all review information and documents
    class AppSubmission < TunesBase
      # @return (Spaceship::Tunes::Application) A reference to the application
      #   this submission is for
      attr_accessor :application

      # @return (AppVersion) The version to use for this submission
      attr_accessor :version

      # @return (Boolean) Submitted for Review
      attr_accessor :submitted_for_review

      # To pass from the user

      # @deprecated Setted automatically by <tt>add_id_info_uses_idfa</tt> usage
      # @return (Boolean) Ad ID Info - Limits ads tracking
      # <b>DEPRECATED:</b> Use <tt>add_id_info_uses_idfa</tt> instead.
      attr_accessor :add_id_info_limits_tracking

      # @return (Boolean) Ad ID Info - Serves ads
      attr_accessor :add_id_info_serves_ads

      # @return (Boolean) Ad ID Info - Tracks actions
      attr_accessor :add_id_info_tracks_action

      # @return (Boolean) Ad ID Info - Tracks installs
      attr_accessor :add_id_info_tracks_install

      # @return (Boolean) Ad ID Info - Uses idfa
      attr_accessor :add_id_info_uses_idfa

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
        'adIdInfo.usesIdfa.value' => :add_id_info_uses_idfa,

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
        def create(application, version)
          attrs = client.prepare_app_submissions(application.apple_id, application.edit_version.version_id)
          attrs[:application] = application
          attrs[:version] = version

          return self.factory(attrs)
        end
      end

      # Save and complete the app submission
      def complete!
        raw_data_clone = raw_data.dup
        if self.content_rights_has_rights.nil? || self.content_rights_contains_third_party_content.nil?
          raw_data_clone.set(["contentRights"], nil)
        end
        raw_data_clone.delete("version")

        # Check whether the application makes use of IDFA or not
        # and automatically set the mandatory limitsTracking value in the request JSON accordingly.
        if !self.add_id_info_uses_idfa.nil? && self.add_id_info_uses_idfa == true
          # Application uses IDFA, before sending for submission limitsTracking key in the request JSON must be set to true (agreement).
          raw_data_clone.set(
            ["adIdInfo", "limitsTracking", "value"],
            true
          )
        end

        client.send_app_submission(application.apple_id, application.edit_version.version_id, raw_data_clone)
        @submitted_for_review = true
      end

      def setup
        @submitted_for_review = false
      end
    end
  end
end
