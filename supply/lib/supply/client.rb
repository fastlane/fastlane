require 'googleauth'
require 'google/apis/androidpublisher_v2'
Androidpublisher = Google::Apis::AndroidpublisherV2

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
      unless Supply.config[:json_key] || Supply.config[:json_key_data] || (Supply.config[:key] && Supply.config[:issuer])
        UI.important("To not be asked about this value, you can specify it using 'json_key'")
        Supply.config[:json_key] = UI.input("The service account json file used to authenticate with Google: ")
      end

      if Supply.config[:json_key]
        service_account_json = File.open(File.expand_path(Supply.config[:json_key]))
      elsif Supply.config[:json_key_data]
        service_account_json = StringIO.new(Supply.config[:json_key_data])
      end

      return Client.new(path_to_key: Supply.config[:key],
                        issuer: Supply.config[:issuer], service_account_json: service_account_json)
    end

    # Initializes the android_publisher and its auth_client using the specified information
    # @param service_account_json: The raw service account Json data
    # @param path_to_key: The path to your p12 file (@deprecated)
    # @param issuer: Email address for oauth (@deprecated)
    def initialize(path_to_key: nil, issuer: nil, service_account_json: nil)
      scope = Androidpublisher::AUTH_ANDROIDPUBLISHER

      if service_account_json
        key_io = service_account_json
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

      if FastlaneCore::Env.truthy?("DEBUG")
        Google::Apis.logger.level = Logger::DEBUG
      end

      Google::Apis::ClientOptions.default.application_name = "fastlane - supply"
      Google::Apis::ClientOptions.default.application_version = Fastlane::VERSION
      Google::Apis::ClientOptions.default.read_timeout_sec = Supply.config[:timeout]
      Google::Apis::ClientOptions.default.open_timeout_sec = Supply.config[:timeout]
      Google::Apis::ClientOptions.default.send_timeout_sec = Supply.config[:timeout]
      Google::Apis::RequestOptions.default.retries = 5

      self.android_publisher = Androidpublisher::AndroidPublisherService.new
      self.android_publisher.authorization = auth_client
      if Supply.config[:root_url]
        # Google's client expects the root_url string to end with "/".
        Supply.config[:root_url] << '/' unless Supply.config[:root_url].end_with?('/')
        self.android_publisher.root_url = Supply.config[:root_url]
      end
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

    # Get a list of all APK version codes - returns the list of version codes
    def apks_version_codes
      ensure_active_edit!

      result = call_google_api { android_publisher.list_apks(current_package_name, current_edit.id) }

      return Array(result.apks).map(&:version_code)
    end

    # Get a list of all AAB version codes - returns the list of version codes
    def aab_version_codes
      ensure_active_edit!

      result = call_google_api { android_publisher.list_edit_bundles(current_package_name, current_edit.id) }

      return Array(result.bundles).map(&:version_code)
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

    def upload_mapping(path_to_mapping, apk_version_code)
      ensure_active_edit!

      call_google_api do
        android_publisher.upload_edit_deobfuscationfile(
          current_package_name,
          current_edit.id,
          apk_version_code,
          "proguard",
          upload_source: path_to_mapping,
          content_type: "application/octet-stream"
        )
      end
    end

    def upload_bundle(path_to_aab)
      ensure_active_edit!

      result_upload = call_google_api do
        android_publisher.upload_edit_bundle(
          current_package_name,
          self.current_edit.id,
          upload_source: path_to_aab,
          content_type: "application/octet-stream"
        )
      end

      return result_upload.version_code
    end

    # Updates the track for the provided version code(s)
    def update_track(track, rollout, apk_version_code)
      ensure_active_edit!

      track_version_codes = apk_version_code.kind_of?(Array) ? apk_version_code : [apk_version_code]

      # This change happend on 2018-04-24
      # rollout cannot be sent on any other track besides "rollout"
      # https://github.com/fastlane/fastlane/issues/12372
      rollout = nil unless track == "rollout"

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

      begin
        result = android_publisher.get_track(
          current_package_name,
          current_edit.id,
          track
        )
        return result.version_codes || []
      rescue Google::Apis::ClientError => e
        return [] if e.status_code == 404 && e.to_s.include?("trackEmpty")
        raise
      end
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
      UI.user_error!("Google Api Error: #{e.message}")
    end
  end
end
