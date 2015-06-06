module Deliver
  class App
    attr_accessor :apple_id, :app_identifier, :metadata


    # Defines the different states of the app
    # 
    # As specified by Apple: https://developer.apple.com/library/ios/documentation/LanguagesUtilities/Conceptual/iTunesConnect_Guide/Chapters/ChangingAppStatus.html
    module AppStatus
      PREPARE_FOR_SUBMISSION = "Prepare for Submission"
      WAITING_FOR_REVIEW = "Waiting For Review"
      IN_REVIEW = "In Review"
      UPLOAD_RECEIVED = "Upload Received"
      PENDING_DEVELOPER_RELEASE = "Pending Developer Release"
      PROCESSING_FOR_APP_STORE = "Processing for App Store"
      READY_FOR_SALE = "Ready for Sale"
      REJECTED = "Rejected"


      # Unused app states
      # PENDING_APPLE_RELASE="Pending Apple Release"
      # PENDING_CONTRACT = "Pending Contract"
      # WAITING_FOR_EXPORT_COMPLIANCE = "Waiting For Export Compliance"
      # METADATA_REJECTED = "Metadata Rejected"
      # REMOVED_FROM_SALE = "Removed From Sale"
      # DEVELOPER_REJECTED = "Developer Rejected" # equals PREPARE_FOR_SUBMISSION
      # DEVELOPER_REMOVED_FROM_SALE = "Developer Removed From Sale"
      # INVALID_BINARY = "Invalid Binary"
    end

    # @param apple_id The Apple ID of the app you want to modify or update. This ID has usually 9 digits
    # @param app_identifier If you don't pass this, it will automatically be fetched from the Apple API
    #   which means it takes longer. If you **can** pass the app_identifier (e.g. com.facebook.Facebook) do it
    def initialize(apple_id: nil, app_identifier: nil)
      self.apple_id = apple_id.to_s.gsub('id', '').to_i
      self.app_identifier = app_identifier
      
      if apple_id and not app_identifier
        # Fetch the app identifier based on the given Apple ID
        self.app_identifier = FastlaneCore::ItunesSearchApi.fetch_bundle_identifier(apple_id)
      elsif app_identifier and not apple_id
        # Fetch the Apple ID based on the given app identifier
        begin
          begin
            self.apple_id = FastlaneCore::ItunesSearchApi.fetch_by_identifier(app_identifier)['trackId']
          rescue
            Helper.log.warn "App doesn't seem to be in the App Store yet or is not available in the US App Store. Using the iTC API instead."
            # Use the iTunes Connect API instead: make that default in the future
            self.apple_id = FastlaneCore::ItunesConnect.new.find_apple_id(app_identifier)
            raise "Couldn't find Apple ID" unless self.apple_id
          end
        rescue
          unless Helper.is_test?
            Helper.log.info "Could not find Apple ID based on the app identifier in the US App Store. Maybe the app is not yet in the store?".yellow
            Helper.log.info "You can provide the Apple ID of your app using `apple_id '974739333'` in your `Deliverfile`".green

            while ((self.apple_id || '').to_s.length == 0) || ((self.apple_id || 0).to_i == 0)
              self.apple_id = ask("\nApple ID of your app (e.g. 284882215): ")
            end
          else
            raise "Please pass a valid Apple ID using 'apple_id'".red
          end
        end
      end
    end

    def to_s
      "#{apple_id} - #{app_identifier}"
    end

    #####################################################
    # @!group Interacting with iTunesConnect
    #####################################################

    # The iTC handler which is used to interact with the iTunesConnect backend
    def itc
      @itc ||= Deliver::ItunesConnect.new
    end

    # This method fetches the current app status from iTunesConnect.
    # This method may take some time to execute, since it uses frontend scripting under the hood.
    # @return the current App Status defined at {Deliver::App::AppStatus}, like "Waiting For Review"
    def get_app_status
      itc.get_app_status(self)
    end

    # This method fetches the app version of the latest published version
    # This method may take some time to execute, since it uses frontend scripting under the hood.
    # @return the currently active app version, which in production
    def get_live_version
      itc.get_live_version(self)
    end


    #####################################################
    # @!group Updating the App Metadata
    #####################################################

    # Use this method to change the default download location for the metadata packages
    def set_metadata_directory(dir)
      raise "Can not change metadata directory after accessing metadata of an app" if @metadata
      @metadata_dir = dir
    end

    # @return the path to the directy in which the itmsp files will be downloaded
    def get_metadata_directory
      return @metadata_dir if @metadata_dir 
      return "./spec/fixtures/packages/" if Helper.is_test?
      return "./"
    end

    # Access to update the metadata of this app
    # 
    # The first time accessing this, will take some time, since it's downloading
    # the latest version from iTC.
    # 
    # Don't forget to call {#upload_metadata!} once you are finished
    # @return [Deliver::AppMetadata] the latest metadata of this app
    def metadata
      @metadata ||= Deliver::AppMetadata.new(self, get_metadata_directory)
    end

    # Was the app metadata already downloaded?
    def metadata_downloaded?
      @metadata != nil
    end


    # Uploads a new app icon to iTunesConnect. This uses a headless browser
    # which makes this command quite slow.
    # @param (path) a path to the new app icon. The image must have the resolution of 1024x1024
    def upload_app_icon!(path)
      itc.upload_app_icon!(self, path)
    end

    # Uploads a new apple watch app icon to iTunesConnect. This uses a headless browser
    # which makes this command quite slow.
    # @param (path) a path to the new apple watch app icon. The image must have the resolution of 1024x1024
    def upload_apple_watch_app_icon!(path)
      itc.upload_apple_watch_app_icon!(self, path)
    end
    #####################################################
    # @!group Destructive/Constructive methods
    #####################################################

    # This method creates a new version of your app using the
    # iTunesConnect frontend. This will happen directly after calling
    # this method. 
    # @param version_number (String) the version number as string for 
    # the new version that should be created
    def create_new_version!(version_number)
      itc.create_new_version!(self, version_number)
    end

    # This method has to be called, after modifying the values of .metadata.
    # It will take care of uploading all changes to Apple.
    # This method might take a few minutes to run
    # @return [bool] true on success
    # @raise [Deliver::TransporterTransferError]
    # @raise [Deliver::TransporterInputError]
    def upload_metadata!
      raise "You first have to modify the metadata using app.metadata.setDescription" unless @metadata
      
      self.metadata.upload!
    end
  end
end
