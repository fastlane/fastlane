module Spaceship
  module Tunes
    # Defines the different states of the app
    #
    # As specified by Apple: https://developer.apple.com/library/ios/documentation/LanguagesUtilities/Conceptual/iTunesConnect_Guide/Chapters/ChangingAppStatus.html
    module AppStatus
      # You can edit this version, upload new binaries and more
      PREPARE_FOR_SUBMISSION = "Prepare for Submission"

      # App is currently live in the App Store
      READY_FOR_SALE = "Ready for Sale"

      # Waiting for Apple's Review
      WAITING_FOR_REVIEW = "Waiting For Review"

      # Currently in Review
      IN_REVIEW = "In Review"

      # App rejected for whatever reason
      REJECTED = "Rejected"

      # The developer took the app from the App Store
      DEVELOPER_REMOVED_FROM_SALE = "Developer Removed From Sale"

      # Developer rejected this version/binary
      DEVELOPER_REJECTED = "Developer Rejected"

      # You have to renew your Apple account to keep using iTunes Connect
      PENDING_CONTRACT = "Pending Contract"

      UPLOAD_RECEIVED = "Upload Received"
      PENDING_DEVELOPER_RELEASE = "Pending Developer Release"
      PROCESSING_FOR_APP_STORE = "Processing for App Store"
      # WAITING_FOR_EXPORT_COMPLIANCE = "Waiting For Export Compliance"
      METADATA_REJECTED = "Metadata Rejected"
      REMOVED_FROM_SALE = "Removed From Sale"
      # INVALID_BINARY = "Invalid Binary"

      # Get the app status matching based on a string (given by iTunes Connect)
      def self.get_from_string(text)
        mapping = {
          'readyForSale' => READY_FOR_SALE,
          'prepareForUpload' => PREPARE_FOR_SUBMISSION,
          'devRejected' => DEVELOPER_REJECTED,
          'pendingContract' => PENDING_CONTRACT,
          'developerRemovedFromSale' => DEVELOPER_REMOVED_FROM_SALE,
          'waitingForReview' => WAITING_FOR_REVIEW,
          'inReview' => IN_REVIEW,
          'rejected' => REJECTED,
          'pendingDeveloperRelease' => PENDING_DEVELOPER_RELEASE,
          'metadataRejected' => METADATA_REJECTED,
          'removedFromSale' => REMOVED_FROM_SALE
        }

        mapping.each do |k, v|
          return v if k == text
        end

        return nil
      end
    end
  end
end
