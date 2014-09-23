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


    def initialize(apple_id = nil)
      if apple_id
        self.apple_id = apple_id
        self.app_identifier = IosDeployKit::ItunesSearchApi.fetch_bundle_identifier(apple_id)
        Helper.log.debug "Created app with ID #{apple_id} and app_identifier #{self.app_identifier}"
      end
    end

    def itc
      @itc ||= IosDeployKit::ItunesConnect.new
    end

    def open_in_itunes_connect
      itc.open_app_page(self)
    end

    def get_app_status
      itc.get_app_status(self)
    end

    def to_s
      "#{apple_id} - #{app_identifier}"
    end

    # Destructive/Constructive methods

    def create_new_version!(version_number)
      itc.create_new_version!(self, version_number)
    end
  end
end