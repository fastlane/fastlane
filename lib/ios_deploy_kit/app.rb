module IosDeployKit
  class App
    attr_accessor :apple_id, :app_identifier, :metadata, :metadata_dir



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


    # @param apple_id The Apple ID of the app you want to modify or update. This ID has usually 9 digits
    # @param app_identifier If you don't pass this, it will automatically be fetched from the Apple API
    #   which means it takes longer. If you **can** pass the app_identifier (e.g. com.facebook.Facebook) do it
    def initialize(apple_id = nil, app_identifier = nil)
      self.apple_id = apple_id
      self.app_identifier = app_identifier
      
      if apple_id and not app_identifier
        # Fetch the app identifier based on the given Apple ID
        self.app_identifier = IosDeployKit::ItunesSearchApi.fetch_bundle_identifier(apple_id)
      end
    end

    def itc
      @itc ||= IosDeployKit::ItunesConnect.new
    end

    def open_in_itunes_connect
      itc.open_app_page(self)
    end

    # This method fetches the current app status from iTunesConnect.
    # This method may take some time to execute, since it uses frontend scripting under the hood.
    # @return the current App Status defined at {IosDeployKit::App::AppStatus}, like "Waiting For Review"
    def get_app_status
      itc.get_app_status(self)
    end

    def to_s
      "#{apple_id} - #{app_identifier}"
    end

    # Use this method to change the default download location for the metadata packages
    def set_metadata_directory(dir)
      raise "Can not change metadata directory after accessing metadata of an app" if @metadata
      self.metadata_dir = dir
    end

    # @return the path to the directy in which the itmsp files will be downloaded
    def get_metadata_directory
      metadata_dir || "./"
    end

    # Access to update the metadata of this app
    # 
    # The first time accessing this, will take some time, since it's downloading
    # the latest version from iTC.
    # 
    # Don't forget to call {#upload_metadata!} once you are finished
    # @return [IosDeployKit::AppMetadata] the latest metadata of this app
    def metadata
      @metadata ||= IosDeployKit::AppMetadata.new(self, get_metadata_directory)
    end


    #####################################################
    # Destructive/Constructive methods
    #####################################################

    def create_new_version!(version_number)
      itc.create_new_version!(self, version_number)
    end

    # This method has to be called, after modifying the values of .metadata.
    # It will take care of uploading all changes to Apple.
    # This method might take a few minutes to run
    # @return [bool] true on success
    # @raise [IosDeployKit::TransporterTransferError]
    # @raise [IosDeployKit::TransporterInputError]
    def upload_metadata!
      raise "You first have to modify the metadata using app.metadata.setDescription" unless @metadata
      
      self.metadata.upload!
    end


  end
end