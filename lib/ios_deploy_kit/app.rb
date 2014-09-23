module IosDeployKit
  class App
    attr_accessor :apple_id, :app_identifier

    module AppStatus
      # As specified by Apple: https://developer.apple.com/library/ios/documentation/LanguagesUtilities/Conceptual/iTunesConnect_Guide/Chapters/ChangingAppStatus.html
      PREPARE_FOR_SUBMISSION = "Prepare for Submission"
      WAITING_FOR_REVIEW = "Waiting For Review"
      IN_REVIEW = "In Review"
      UPLOAD_RECEIVED = "Upload Received"
      # PENDING_CONTRACT = "Pending Contract"
      # WAITING_FOR_EXPORT_COMPLIANCE = "Waiting For Export Compliance"
      PENDING_DEVELOPER_RELEASE = "Pending Developer Release"
      PROCESSING_FOR_APP_STORE = "Processing for App Store"
      # PENDING_APPLE_RELASE="Pending APple Release"
      READY_FOR_SALE = "Ready for Sale"
      REJECTED = "Rejected"
      # METADATA_REJECTED = "Metadata Rejected"
      # REMOVED_FROM_SALE = "Removed From Sale"
      # DEVELOPER_REJECTED = "Developer Rejected" # equals PREPARE_FOR_SUBMISSION
      # DEVELOPER_REMOVED_FROM_SALE = "Developer Removed From Sale"
      # INVALID_BINARY = "Invalid Binary"
    end



    def itc
      unless @itc
        @itc = IosDeployKit::ItunesConnect.new
        @itc.login
      end
      @itc
    end

    def open_in_itunes_connect
      itc.open_app_page(self)
    end

    def create_new_version(version_number)
      itc.create_new_version(self, version_number)
    end

    def to_s
      "#{apple_id} - #{app_identifier}"
    end
  end
end