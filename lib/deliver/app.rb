module Deliver
  class App
    attr_accessor :apple_id, :app_identifier, :metadata

    # @param apple_id The Apple ID of the app you want to modify or update. This ID has usually 9 digits
    # @param app_identifier If you don't pass this, it will automatically be fetched from the Apple API
    #   which means it takes longer. If you **can** pass the app_identifier (e.g. com.facebook.Facebook) do it
    def initialize(apple_id: nil, app_identifier: nil)
      self.apple_id = apple_id.to_s.gsub('id', '').to_i
      self.app_identifier = app_identifier
      
      app_ref = Spaceship::Tunes::Application.find(self.app_identifier || self.apple_id) # the order is important
      raise "Could not find app (#{apple_id} #{app_identifier})" unless app_ref
      self.apple_id = app_ref.apple_id
      self.app_identifier = app_ref.bundle_id

      @ref = app_ref # since we have it already, why not store it? :) 
    end

    def to_s
      "#{apple_id} - #{app_identifier}"
    end

    #####################################################
    # @!group Interacting with iTunesConnect
    #####################################################

    # Reference to the spaceship app object
    def spaceship_ref
      @ref ||= Spaceship::Tunes::Application.find(self.app_identifier)
    end

    # This method fetches the current app status from iTunesConnect.
    # This method may take some time to execute, since it uses frontend scripting under the hood.
    # @return the current App Status defined at {Spaceship::Tunes::AppStatus}, like "Waiting For Review"
    def get_app_status
      spaceship_ref.latest_version.app_status
    end

    # This method fetches the app version of the latest published version
    # @return the currently active app version, which in production
    def get_live_version
      spaceship_ref.latest_version.version
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
      if (v = spaceship_ref.edit_version)
        if v.version != version_number
          # Version is already there, make sure it matches the one we want to create
          Helper.log.info "Changing existing version number from '#{v.version}' to '#{version_number}'"
          v.version = version_number
          v.save!
        end
      else
        # No version created yet, creating it now
        spaceship_ref.create_version!(version_number)
      end
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
