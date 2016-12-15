require 'googleauth'
require 'google/apis/androidpublisher_v2'
Androidpublisher = Google::Apis::AndroidpublisherV2
CredentialsLoader = Google::Auth::CredentialsLoader

require 'net/http'

module Supply
  class Client
    # Connecting with Google
    attr_accessor :android_publisher

    # Editing something
    # Reference to the entry we're currently editing. Might be nil if don't have one open
    attr_accessor :current_edit
    # Package name of the currently edited element
    attr_accessor :current_package_name

    #####################################################
    # @!group Login
    #####################################################

    # instantiate a client given the supplied configuration
    def self.make_from_config
      unless Supply.config[:json_key] || (Supply.config[:key] && Supply.config[:issuer])
        UI.important("To not be asked about this value, you can specify it using 'json_key'")
        Supply.config[:json_key] = UI.input("The service account json file used to authenticate with Google: ")
      end

      return Client.new(path_to_key: Supply.config[:key],
                        issuer: Supply.config[:issuer],
                        path_to_service_account_json: Supply.config[:json_key])
    end

    # Initializes the android_publisher and its auth_client using the specified information
    # @param path_to_service_account_json: The path to your service account Json file
    # @param path_to_key: The path to your p12 file (@deprecated)
    # @param issuer: Email addresss for oauth (@deprecated)
    def initialize(path_to_key: nil, issuer: nil, path_to_service_account_json: nil)
      scope = Androidpublisher::AUTH_ANDROIDPUBLISHER

      if path_to_service_account_json
        key_io = File.open(File.expand_path(path_to_service_account_json))
      else
        require 'google/api_client/auth/key_utils'
        key = Google::APIClient::KeyUtils.load_from_pkcs12(File.expand_path(path_to_key), 'notasecret')
        cred_json = {
          private_key: key.to_s,
          client_email: issuer
        }
        key_io = StringIO.new(MultiJson.dump(cred_json))
      end

      auth_client = Google::Auth::ServiceAccountCredentials.make_creds(json_key_io: key_io, scope: scope)

      UI.verbose("Fetching a new access token from Google...")

      auth_client.fetch_access_token!

      if ENV["DEBUG"]
        Google::Apis.logger.level = Logger::DEBUG
      end

      Google::Apis::ClientOptions.default.application_name = "fastlane - supply"
      Google::Apis::ClientOptions.default.application_version = Fastlane::VERSION
      Google::Apis::RequestOptions.default.timeout_sec = 300
      Google::Apis::RequestOptions.default.open_timeout_sec = 300
      Google::Apis::RequestOptions.default.retries = 5

      self.android_publisher = Androidpublisher::AndroidPublisherService.new
      self.android_publisher.authorization = auth_client
    end

    #####################################################
    # @!group Handling the edit lifecycle
    #####################################################

    # Begin modifying a certain package
    def begin_edit(package_name: nil)
      UI.user_error!("You currently have an active edit") if @current_edit

      self.current_edit = call_google_api { android_publisher.insert_edit(package_name) }

      self.current_package_name = package_name
    end

    # Aborts the current edit deleting all pending changes
    def abort_current_edit
      ensure_active_edit!

      call_google_api { android_publisher.delete_edit(current_package_name, current_edit.id) }

      self.current_edit = nil
      self.current_package_name = nil
    end

    # Validates the current edit - does not change data on Google Play
    def validate_current_edit!
      ensure_active_edit!

      call_google_api { android_publisher.validate_edit(current_package_name, current_edit.id) }
    end

    # Commits the current edit saving all pending changes on Google Play
    def commit_current_edit!
      ensure_active_edit!

      call_google_api { android_publisher.commit_edit(current_package_name, current_edit.id) }

      self.current_edit = nil
      self.current_package_name = nil
    end

    #####################################################
    # @!group Getting data
    #####################################################

    # Get a list of all languages - returns the list
    # make sure to have an active edit
    def listings
      ensure_active_edit!

      result = call_google_api { android_publisher.list_listings(current_package_name, current_edit.id) }

      return result.listings.map do |row|
        Listing.new(self, row.language, row)
      end
    end

    # Returns the listing for the given language filled with the current values if it already exists
    def listing_for_language(language)
      ensure_active_edit!

      begin
        result = android_publisher.get_listing(
          current_package_name,
          current_edit.id,
          language
        )

        return Listing.new(self, language, result)
      rescue Google::Apis::ClientError => e
        return Listing.new(self, language) if e.status_code == 404 # create a new empty listing
        raise
      end
    end

    # Get a list of all apks verion codes - returns the list of version codes
    def apks_version_codes
      ensure_active_edit!

      result = call_google_api { android_publisher.list_apks(current_package_name, current_edit.id) }

      return result.apks.map(&:version_code)
    end

    # Get a list of all apk listings (changelogs) - returns the list
    def apk_listings(apk_version_code)
      ensure_active_edit!

      result = call_google_api do
        android_publisher.list_apk_listings(
          current_package_name,
          current_edit.id,
          apk_version_code
        )
      end

      return (result.listings || []).map do |row|
        ApkListing.new(row.recent_changes, row.language, apk_version_code)
      end
    end

    #####################################################
    # @!group Modifying data
    #####################################################

    # Updates or creates the listing for the specified language
    def update_listing_for_language(language: nil, title: nil, short_description: nil, full_description: nil, video: nil)
      ensure_active_edit!

      listing = Androidpublisher::Listing.new({
        language: language,
        title: title,
        full_description: full_description,
        short_description: short_description,
        video: video
      })

      call_google_api do
        android_publisher.update_listing(
          current_package_name,
          current_edit.id,
          language,
          listing
        )
      end
    end

    def upload_apk(path_to_apk)
      ensure_active_edit!

      result_upload = call_google_api do
        android_publisher.upload_apk(
          current_package_name,
          current_edit.id,
          upload_source: path_to_apk
        )
      end

      return result_upload.version_code
    end

    # Updates the track for the provided version code(s)
    def update_track(track, rollout, apk_version_code)
      ensure_active_edit!

      track_version_codes = apk_version_code.kind_of?(Array) ? apk_version_code : [apk_version_code]

      track_body = Androidpublisher::Track.new({
        track: track,
        user_fraction: rollout,
        version_codes: track_version_codes
      })

      call_google_api do
        android_publisher.update_track(
          current_package_name,
          current_edit.id,
          track,
          track_body
        )
      end
    end

    # Get list of version codes for track
    def track_version_codes(track)
      ensure_active_edit!

      result = call_google_api do
        android_publisher.get_track(
          current_package_name,
          current_edit.id,
          track
        )
      end

      return result.version_codes
    end

    def update_apk_listing_for_language(apk_listing)
      ensure_active_edit!

      apk_listing_object = Androidpublisher::ApkListing.new({
        language: apk_listing.language,
        recent_changes: apk_listing.recent_changes
      })

      call_google_api do
        android_publisher.update_apk_listing(
          current_package_name,
          current_edit.id,
          apk_listing.apk_version_code,
          apk_listing.language,
          apk_listing_object
        )
      end
    end

    #####################################################
    # @!group Screenshots
    #####################################################

    def fetch_images(image_type: nil, language: nil)
      ensure_active_edit!

      result = call_google_api do
        android_publisher.list_images(
          current_package_name,
          current_edit.id,
          language,
          image_type
        )
      end

      (result.images || []).map(&:url)
    end

    # @param image_type (e.g. phoneScreenshots, sevenInchScreenshots, ...)
    def upload_image(image_path: nil, image_type: nil, language: nil)
      ensure_active_edit!

      call_google_api do
        android_publisher.upload_image(
          current_package_name,
          current_edit.id,
          language,
          image_type,
          upload_source: image_path,
          content_type: 'image/*'
        )
      end
    end

    def clear_screenshots(image_type: nil, language: nil)
      ensure_active_edit!

      call_google_api do
        android_publisher.delete_all_images(
          current_package_name,
          current_edit.id,
          language,
          image_type
        )
      end
    end

    def upload_obb(obb_file_path: nil, apk_version_code: nil, expansion_file_type: nil)
      ensure_active_edit!

      call_google_api do
        android_publisher.upload_expansion_file(
          current_package_name,
          current_edit.id,
          apk_version_code,
          expansion_file_type,
          upload_source: obb_file_path,
          content_type: 'application/octet-stream'
        )
      end
    end

    private

    def ensure_active_edit!
      UI.user_error!("You need to have an active edit, make sure to call `begin_edit`") unless @current_edit
    end

    def call_google_api
      yield if block_given?
    rescue Google::Apis::ClientError => e
      UI.user_error! "Google Api Error: #{e.message}"
    end
  end
end
