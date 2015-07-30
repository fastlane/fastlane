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
      
      # @return (String) The stage of this submission (start, complete)
      attr_accessor :stage
      
      # @return (Boolean) Submitted for Review
      attr_accessor :submitted_for_review

      # @return (Boolean) Ad ID Info - Limits ads tracking
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
        'adIdInfo.limitsTracking.value' => :add_id_info_limits_tracking,
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
        'exportCompliance.encryptionUpdated' => :export_compliance_encryption_updated,
        'exportCompliance.exportComplianceRequired' => :export_compliance_compliance_required,
        'exportCompliance.platform' => :export_compliance_platform
      })

      class << self
        # Create a new object based on a hash.
        # This is used to create a new object based on the server response.
        def factory(attrs)
          orig = attrs.dup
          
          # fill content rights section if iTC returns nil
          if attrs["contentRights"].nil?
            attrs.merge!("contentRights" => {
              "containsThirdPartyContent" => {
                "value" => nil
              },
              "hasRights" => {
                "value" => nil
              }
            })
          end
          
          obj = self.new(attrs)
          return obj
        end
        
        # @param application (Spaceship::Tunes::Application) The app this submission is for
        # @param app_id (String) The unique Apple ID of this app
        def create(application, app_id, version)
          stage = "start"
          attrs = client.send_app_submission(application.apple_id, version.raw_data, stage)
          attrs.merge!(application: application)
          attrs.merge!(version: version)
          attrs.merge!(stage: stage)

          return self.factory(attrs)
        end
      end
      
      # Save and complete the app submission
      def complete!
        @stage = "complete"
        client.send_app_submission(application.apple_id, raw_data, @stage)
        @submitted_for_review = true
      end

      # @return (String) An URL to this specific resource. You can enter this URL into your browser
      def url
        "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/#{self.application.apple_id}/version/submit/#{self.stage}"
      end

      def setup
        @submitted_for_review = false
      end

    end
  end
end
