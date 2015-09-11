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

    # A reference to the spaceship object for this app/version
    # @param refresh Force refresh
    def edit_version(refresh: false)
      @edit = nil if refresh
      @edit ||= spaceship_ref.edit_version
    end

    def metadata
      @metadata ||= Metadata.new(self)
    end

    # This method fetches the current app status from iTunesConnect.
    # This method may take some time to execute, since it uses frontend scripting under the hood.
    # @return the current App Status defined at {Spaceship::Tunes::AppStatus}, like "Waiting For Review"
    def app_status
      spaceship_ref.latest_version.app_status
    end

    # This method fetches the app version of the latest published version
    # @return the currently active app version, which in production
    def live_version_number
      spaceship_ref.latest_version.version
    end

    def can_set_changelog?
      # initial version's live version is ready for submission instead of being live
      spaceship_ref.live_version.app_status != Spaceship::Tunes::AppStatus::PREPARE_FOR_SUBMISSION
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
      if (v = spaceship_ref.edit_version) # fix: sometimes this is nil for some reason
        if v.version != version_number
          # Version is already there, make sure it matches the one we want to create
          Helper.log.info "Changing existing version number from '#{v.version}' to '#{version_number}'"
          v.version = version_number
          v.save!
        end
      else
        # No version created yet, creating it now
        require 'pry'
        binding.pry
        spaceship_ref.create_version!(version_number)
      end
    end
  end
end
