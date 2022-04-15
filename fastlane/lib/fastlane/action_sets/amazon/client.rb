# frozen_string_literal: true

require 'net/http'
require 'net/http/post/multipart'
require 'uri'
require 'json'

require_relative './types/apk_metadata'
require_relative './types/client_credentials'
require_relative './types/details'
require_relative './types/edit'
require_relative './types/listing'

module Fastlane::ActionSets::Amazon
  # Communicates with the API directly.
  class Client
    # @return [Time] The time when the credentials were last fetched
    attr_reader :last_authenticated
    attr_accessor :client_id, :client_secret, :etag_cache

    # @param [String] client_id The Amazon Appstore API client ID; defaults to
    #   `$AMAZON_APP_SUBMISSION_API_CLIENT_ID`
    # @param [String] client_secret The Amazon Appstore API client secret; defaults to
    #   `$AMAZON_APP_SUBMISSION_API_CLIENT_SECRET`
    # @param [ClientCredentials] client_credentials Any saved credentials to use (like from a
    #   preexisting session)
    def initialize(client_id: nil, client_secret: nil, client_credentials: nil)
      @base_url = URI('https://developer.amazon.com/api/appstore/')
      @client_id = client_id || ENV['AMAZON_APP_SUBMISSION_API_CLIENT_ID']
      @client_secret = client_secret || ENV['AMAZON_APP_SUBMISSION_API_CLIENT_SECRET']
      if client_credentials
        @client_credentials = client_credentials
        @last_authenticated = Time.now
      end
      @etag_cache = {}
    end

    # Authentication functions

    # Gets a new access token from the Amazon API only if it is needed.
    #
    # @return [ClientCredentials]
    def authenticate_if_needed
      return @client_credentials unless needs_authentication?
      authenticate!
    end

    # Determines if our credentials are invalid or out of date.
    #
    # @return [Boolean]
    def needs_authentication?
      if @client_credentials.nil? || @last_authenticated.nil?
        return true
      elsif (@last_authenticated + @client_credentials.expires_in) < Time.now
        return true
      else
        return false
      end
    end

    # Authenticates regardless of previous session status.
    #
    # @return [ClientCredentials]
    def authenticate!
      if @client_id.nil? || @client_secret.nil?
        raise "Need #client_id and #client_secret to be defined"
      end

      uri = URI('https://api.amazon.com/auth/o2/token')
      body = {
        'client_id' => @client_id,
        'client_secret' => @client_secret,
        'grant_type' => 'client_credentials',
        'scope' => 'appstore::apps:readwrite'
      }

      headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
      response, _ = make_request(uri, verb: :post, body: body, headers: headers)
      @client_credentials = ClientCredentials.new(response)
      @last_authenticated = Time.now
      return @client_credentials
    end

    # Edits

    # Returns information about the active edit for the app. Note: returns an
    # empty response if no open edit exists.
    #
    # @param [String] app_id The package name or app identifier for the app
    #
    # @return [Edit]
    def get_active_edit(app_id:)
      edit, etag = do_get("v1/applications/#{app_id}/edits")
      @etag_cache[edit['id']] = etag
      return edit.empty? ? nil : Edit.new(edit)
    end

    # Creates a new edit (upcoming release) for an existing app. The Edit is
    # populated with values from the live version of the app. Note: An app can
    # have only one edit open at once. This operation fails if an edit already
    # exists for the given app.
    #
    # @param [String] app_id The package name or app identifier for the app
    #
    # @return [Edit]
    def create_edit(app_id:)
      edit, etag = do_post("v1/applications/#{app_id}/edits")
      @etag_cache[edit['id']] = etag
      return Edit.new(edit)
    end

    # Returns information about the specified edit.
    #
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    #
    # @return [Edit]
    def get_edit(edit_id, app_id:)
      edit, etag = do_get("v1/applications/#{app_id}/edits/#{edit_id}")
      @etag_cache[edit_id] = etag
      return Edit.new(edit)
    end

    # Deletes the specified edit.
    #
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    def delete_edit(edit_id, app_id:)
      path = "v1/applications/#{app_id}/edits/#{edit_id}"
      do_delete(path, etag: @etag_cache[edit_id])
      @etag_cache.delete(edit_id)
      return nil
    end

    # Checks that the changes in the edit are valid. Returns the edit if all
    # validations succeed. Returns a 403 with list of validation errors
    # otherwise.
    #
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    #
    # @return [Edit]
    def validate_edit(edit_id, app_id:)
      path = "v1/applications/#{app_id}/edits/#{edit_id}/validate"
      edit, _ = do_post(path, etag: @etag_cache[edit_id])
      return Edit.new(edit)
    end

    # Marks the edit as submitted, making the changes in the edit live if all
    # validations succeed. Returns a 403 with the list of validation failures
    # otherwise.
    #
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    #
    # @return [Edit]
    def commit_edit(edit_id, app_id:)
      path = "v1/applications/#{app_id}/edits/#{edit_id}/commit"
      edit, _ = do_post(path, etag: @etag_cache[edit_id])
      return Edit.new(edit)
    end

    # Listings

    # Gets information related to all localized listings.
    #
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    #
    # @return [Hash<String, Listing>]
    def get_listings(edit_id:, app_id:)
      listings, _ = do_get("v1/applications/#{app_id}/edits/#{edit_id}/listings")
      return listings['listings'].each_with_object({}) do |(key, value), obj|
        obj[key] = Listing.new(value)
      end
    end

    # Gets information about the localized listing for a given language.
    #
    # @param [String] language The language (such as en-US)
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    #
    # @return [Listing]
    def get_listing(language, edit_id:, app_id:)
      etag_key = [edit_id, language].join('-')
      listing, etag = do_get("v1/applications/#{app_id}/edits/#{edit_id}/listings/#{language}")
      @etag_cache[etag_key] = etag
      return Listing.new(listing)
    end

    # Modifies information related to a localized listing.
    #
    # @param [Listing] listing The listing to modify
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    #
    # @return [Listing]
    def update_listing(listing, edit_id:, app_id:)
      language = listing.language
      etag_key = [edit_id, language].join('-')
      path = "v1/applications/#{app_id}/edits/#{edit_id}/listings/#{language}"
      listing_json, etag = do_put(path, listing.to_json, etag: @etag_cache[etag_key])
      @etag_cache[etag_key] = etag
      return Listing.new(listing_json)
    end

    # Removes the localized listing for the given language. Note: Cannot remove
    # the listing for the default language.
    #
    # @param [String] language The language (such as en-US)
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    def delete_listing(language, edit_id:, app_id:)
      etag_key = [edit_id, language].join('-')
      path = "v1/applications/#{app_id}/edits/#{edit_id}/listings/#{language}"
      do_delete(path, etag: @etag_cache[etag_key])
      @etag_cache.delete(etag_key)
      return nil
    end

    # Details

    # Get app details such as contact information and default language for the
    # given edit.
    #
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    #
    # @return [Details]
    def get_details(edit_id:, app_id:)
      details, etag = do_get("v1/applications/#{app_id}/edits/#{edit_id}/details")
      etag_key = [edit_id, 'details'].join('-')
      @etag_cache[etag_key] = etag
      return Details.new(details)
    end

    # Update app details for the given edit. Note: Default language cannot be
    # changed.
    #
    # @param [Details] details The details object to update
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    #
    # @return [Details]
    def update_details(details, edit_id:, app_id:)
      etag_key = [edit_id, 'details'].join('-')
      path = "v1/applications/#{app_id}/edits/#{edit_id}/details"
      details_json, etag = do_put(path, details.to_json, etag: @etag_cache[etag_key])
      @etag_cache[etag_key] = etag
      return Details.new(details_json)
    end

    # APKs

    # List all APKs for the given app.
    #
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    #
    # @return [Array<APKMetadata>]
    def get_apks(edit_id:, app_id:)
      apks, _ = do_get("v1/applications/#{app_id}/edits/#{edit_id}/apks")
      return apks.map { |json| APKMetadata.new(json) }
    end

    # Gets a specified APK for the given app.
    #
    # @param [String] apk_id The identifier of the APK
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    #
    # @return [APKMetadata]
    def get_apk(apk_id, edit_id:, app_id:)
      apk, etag = do_get("v1/applications/#{app_id}/edits/#{edit_id}/apks/#{apk_id}")
      @etag_cache[apk_id] = etag
      return APKMetadata.new(apk)
    end

    # Deletes a specified APK for the given app.
    #
    # @param [String] apk_id The identifier of the APK
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    def delete_apk(apk_id, edit_id:, app_id:)
      path = "v1/applications/#{app_id}/edits/#{edit_id}/apks/#{apk_id}"
      do_delete(path, etag: @etag_cache[apk_id])
      @etag_cache.delete(apk_id)
      return nil
    end

    # Replaces a specified APK for the given app. Preserves the targeting
    # information for that APK.
    #
    # @param [String] apk_id The identifier of the APK
    # @param [String] apk_filepath The path to the APK file to upload
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    #
    # @return [APKMetadata]
    def replace_apk(apk_id, apk_filepath:, edit_id:, app_id:)
      path = "v1/applications/#{app_id}/edits/#{edit_id}/apks/#{apk_id}/replace"
      body, headers = upload_body_and_headers(apk_filepath)
      apk_metadata, etag = do_put(path, body, headers: headers, etag: @etag_cache[apk_id])
      @etag_cache[apk_id] = etag
      return APKMetadata.new(apk_metadata)
    end

    # Upload a new APK for the given app (and attaches it).
    #
    # @param [String] apk_filepath The path to the APK file to upload
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    #
    # @return [APKMetadata]
    def upload_apk(apk_filepath, edit_id:, app_id:)
      path = "v1/applications/#{app_id}/edits/#{edit_id}/apks/upload"
      body, headers = upload_body_and_headers(apk_filepath)
      apk_metadata, _ = do_post(path, body: body, headers: headers)
      return APKMetadata.new(apk_metadata)
    end

    # Upload a new APK for the given app. Used for uploading large APKs.
    #
    # @param [String] apk_filepath The path to the APK file to upload
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    #
    # @return [String] The file identifier of the APK asset (to be used when
    #   attaching this to an APK later with `#attach_apk`)
    def upload_large_apk(apk_filepath, edit_id:, app_id:)
      path = "v1/applications/#{app_id}/edits/#{edit_id}/apks/large/upload"
      mime_type = 'application/vnd.android.package-archive'
      filename = File.basename(apk_filepath)
      body = {
        'file' => UploadIO.new(File.expand_path(apk_filepath), mime_type, filename)
      }
      headers = { 'fileName' => filename }
      upload_metadata, _ = do_post(path, body: body, headers: headers)
      return upload_metadata['fileId']
    end

    # Attaches an uploaded APK to this edit.
    #
    # @param [String] file_id The file identifier of the APK asset to attach
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    #
    # @return [APKMetadata]
    def attach_apk(file_id, edit_id:, app_id:)
      path = "v1/applications/#{app_id}/edits/#{edit_id}/apks/attach"
      body = { 'fileId' => file_id }
      apk, _ = do_post(path, body: body)
      return APKMetadata.new(apk)
    end

    # Images

    # List all images for the given language and image type.
    #
    # Permissible values for `image_type` include: `small-icons`, `large-icons`,
    # `screenshots`, `promo-images`, `firetv-screenshots`, `firetv-icons`,
    # `firetv-backgrounds`, `firetv-featured-backgrounds`,
    # and `firetv-featured-logos`.
    #
    # @param [String] image_type The imageType, as specified in the permissible values
    # @param [String] language The language (such as en-US)
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    #
    # @return [Array<String>] An array of image asset identifiers
    def get_images(image_type, language:, edit_id:, app_id:)
      images, etag = do_get("v1/applications/#{app_id}/edits/#{edit_id}/listings/#{language}/#{image_type}")
      etag_key = [edit_id, language].join('-')
      @etag_cache[etag_key] = etag
      return images['images'].map { |json| json['id'] }
    end

    # Uploads an image and adds it to the list of images for the given language
    # and image type. If the image type only supports a single image (such as
    # icons), the uploaded image replaces the existing image.
    #
    # Permissible values for `image_type` include: `small-icons`, `large-icons`,
    # `screenshots`, `promo-images`, `firetv-screenshots`, `firetv-icons`,
    # `firetv-backgrounds`, `firetv-featured-backgrounds`,
    # and `firetv-featured-logos`.
    #
    # @param [String] filepath The path to the image file to upload
    # @param [String] image_type The imageType, as specified in the permissible values
    # @param [String] language The language (such as en-US)
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    #
    # @return [String] The asset identifier of the image
    def upload_image(filepath, image_type:, language:, edit_id:, app_id:)
      etag_key = [edit_id, language].join('-')
      path = "v1/applications/#{app_id}/edits/#{edit_id}/listings/#{language}/#{image_type}/upload"
      body, headers = upload_body_and_headers(filepath)
      image_metadata, etag = do_post(path, body: body, headers: headers, etag: @etag_cache[etag_key])
      @etag_cache[etag_key] = etag
      return image_metadata['image']['id']
    end

    # Delete a specified image for the given listing.
    #
    # Permissible values for `image_type` include: `small-icons`, `large-icons`,
    # `screenshots`, `promo-images`, `firetv-screenshots`, `firetv-icons`,
    # `firetv-backgrounds`, `firetv-featured-backgrounds`,
    # and `firetv-featured-logos`.
    #
    # @param [String] asset_id The asset ID of the image
    # @param [String] image_type The imageType, as specified in the permissible values
    # @param [String] language The language (such as en-US)
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    def delete_image(asset_id, image_type:, language:, edit_id:, app_id:)
      etag_key = [edit_id, language].join('-')
      path = "v1/applications/#{app_id}/edits/#{edit_id}/listings/#{language}/#{image_type}/#{asset_id}"
      _, etag = do_delete(path, etag: @etag_cache[etag_key])
      @etag_cache[etag_key] = etag
      return nil
    end

    # Deletes all images for the given language and image type.
    #
    # Permissible values for `image_type` include: `small-icons`, `large-icons`,
    # `screenshots`, `promo-images`, `firetv-screenshots`, `firetv-icons`,
    # `firetv-backgrounds`, `firetv-featured-backgrounds`,
    # and `firetv-featured-logos`.
    #
    # @param [String] image_type The imageType, as specified in the permissible values
    # @param [String] language The language (such as en-US)
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    def delete_all_images(image_type, language:, edit_id:, app_id:)
      etag_key = [edit_id, language].join('-')
      path = "v1/applications/#{app_id}/edits/#{edit_id}/listings/#{language}/#{image_type}"
      _, etag = do_delete(path, etag: @etag_cache[etag_key])
      @etag_cache[etag_key] = etag
      return nil
    end

    # Videos

    # List all videos for the given language and video type.
    #
    # @param [String] language The language (such as en-US)
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    #
    # @return [Array<String>] An array of video asset identifiers
    def get_videos(language:, edit_id:, app_id:)
      videos, etag = do_get("v1/applications/#{app_id}/edits/#{edit_id}/listings/#{language}/videos")
      etag_key = [edit_id, language].join('-')
      @etag_cache[etag_key] = etag
      return videos['videos'].map { |json| json['id'] }
    end

    # Uploads a video and adds it to the list of videos for the given language
    # and video type. If the video type only supports a single video, it will
    # be replaced instead.
    #
    # @param [String] filepath The path to the video file to upload
    # @param [String] language The language (such as en-US)
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    #
    # @return [String] The asset identifier of the video
    def upload_video(filepath, language:, edit_id:, app_id:)
      etag_key = [edit_id, language].join('-')
      # NOTE: The Amazon Appstore API documentation denotes this is "…/videos",
      #       but it's really "…/videos/upload"
      path = "v1/applications/#{app_id}/edits/#{edit_id}/listings/#{language}/videos/upload"
      body, headers = upload_body_and_headers(filepath)
      video_metadata, etag = do_post(path, body: body, headers: headers, etag: @etag_cache[etag_key])
      @etag_cache[etag_key] = etag
      return video_metadata['video']['id']
    end

    # Delete a specified video for the given listing.
    #
    # @param [String] asset_id The asset ID of the video
    # @param [String] language The language (such as en-US)
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    def delete_video(asset_id, language:, edit_id:, app_id:)
      etag_key = [edit_id, language].join('-')
      path = "v1/applications/#{app_id}/edits/#{edit_id}/listings/#{language}/videos/#{asset_id}"
      _, etag = do_delete(path, etag: @etag_cache[etag_key])
      @etag_cache[etag_key] = etag
      return nil
    end

    # Delete the videos associated with the specified language.
    #
    # @param [String] language The language (such as en-US)
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    def delete_all_videos(language:, edit_id:, app_id:)
      etag_key = [edit_id, language].join('-')
      path = "v1/applications/#{app_id}/edits/#{edit_id}/listings/#{language}/videos"
      _, etag = do_delete(path, etag: @etag_cache[etag_key])
      @etag_cache[etag_key] = etag
      return nil
    end


    # Availability

    # Returns availiability information for the specified edit.
    #
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    #
    # @return [Availability]
    def get_availability(edit_id:, app_id:)
      etag_key = [edit_id, 'availability'].join('-')
      availability, etag = do_get("v1/applications/#{app_id}/edits/#{edit_id}/availability")
      @etag_cache[etag_key] = etag
      return Availability.new(availability)
    end

    # Updates availiability information for the specified edit.
    #
    # @param [Availability] availability The availability metadata to update
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    #
    # @return [Availability]
    def update_availability(availability, edit_id:, app_id:)
      etag_key = [edit_id, 'availability'].join('-')
      path = "v1/applications/#{app_id}/edits/#{edit_id}/availability"
      availability_json, etag = do_put(path, availability.to_json, etag: @etag_cache[etag_key])
      @etag_cache[etag_key] = etag
      return Availability.new(availability_json)
    end

    # Targeting

    # Gets details about the device targeting for a given APK.
    #
    # @param [String] apk_id The identifier of the APK
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    #
    # @return [Targeting]
    def get_targeting(apk_id:, edit_id:, app_id:)
      etag_key = [apk_id, 'targeting'].join('-')
      targeting, etag = do_get("v1/applications/#{app_id}/edits/#{edit_id}/apks/#{apk_id}/targeting")
      @etag_cache[etag_key] = etag
      return Targeting.new(targeting)
    end

    # Modifies device targeting information for the given APK.
    #
    # @param [Targeting] targeting The targeting metadata to update
    # @param [String] apk_id The identifier of the APK
    # @param [String] edit_id The identifier of the edit
    # @param [String] app_id The package name or app identifier for the app
    #
    # @return [Targeting]
    def update_targeting(targeting, apk_id:, edit_id:, app_id:)
      etag_key = [apk_id, 'targeting'].join('-')
      path = "v1/applications/#{app_id}/edits/#{edit_id}/apks/#{apk_id}/targeting"
      targeting_json, etag = do_put(path, targeting.to_json, etag: @etag_cache[etag_key])
      @etag_cache[etag_key] = etag
      return Targeting.new(targeting_json)
    end

    private

    def do_get(path, body: nil, headers: {})
      raise "Requires authentication" if needs_authentication?
      make_request(path, verb: :get, body: body, headers: headers)
    end

    def do_post(path, body: nil, headers: {}, etag: nil)
      raise "Requires authentication" if needs_authentication?
      make_request(path, verb: :post, body: body, headers: headers, etag: etag)
    end

    def do_put(path, body, headers: {}, etag: nil)
      raise "Requires authentication" if needs_authentication?
      make_request(path, verb: :put, body: body, headers: headers, etag: etag)
    end

    def do_delete(path, body: nil, headers: {}, etag: nil)
      raise "Requires authentication" if needs_authentication?
      make_request(path, verb: :delete, body: body, headers: headers, etag: etag)
    end

    def make_request(path_or_uri, verb:, body:, headers:, etag: nil)
      uri = path_or_uri
      if path_or_uri.is_a?(String)
        uri = URI::join(@base_url, path_or_uri)
      end

      if @client_credentials&.access_token
        headers['Authorization'] = "Bearer #{@client_credentials.access_token}"
      end
      headers['If-Match'] = etag if etag
      request = Request.new(uri, verb: verb, body: body, headers: headers)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.instance_of? URI::HTTPS
      req = request.as_net_http_request
      response = http.request(req)

      case response
      when Net::HTTPSuccess then
        return (response.body ? JSON.parse(response.body) : nil), response['ETag']
      else
        raise "Unexpected HTTP #{response.code} response: #{response.body}"
      end
    end

    def upload_body_and_headers(filepath)
      filename = File.basename(filepath)
      mime_type = mime_type_for_file(filepath)
      body = UploadIO.new(File.expand_path(filepath), mime_type)
      headers = { 'Content-Type' => mime_type, 'fileName' => filename }
      if body.respond_to?(:length)
        headers['Content-Length'] = body.length.to_s
      elsif body.respond_to?(:stat)
        headers['Content-Length'] = body.stat.size.to_s
      end
      return body, headers
    end

    def mime_type_for_file(path)
      Helper.backticks("file --mime-encoding #{path.shellescape}", print: false)
    end
  end

  # Request

  # Encapsulates logic for formulating network requests. Agnostic towards
  # reading files and handling etags; just raw verbs, uris, bodies, and headers.
  class Request
    class << self
      def default_headers
        {
          'User-Agent' => 'fastlane-amazon',
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
        }
      end
    end

    # @return [URI]
    attr_accessor :uri
    # @return [Symbol]
    attr_accessor :verb
    # @return [Object]
    attr_accessor :body
    # @return [Hash<String, String>]
    attr_accessor :headers

    # @param [URI] uri <description>
    # @param [Symbol] verb <description>
    # @param [Object, nil] body <description>
    # @param [Hash<String, String>] headers <description>
    def initialize(uri, verb: :get, body: nil, headers: {})
      @uri = uri
      @verb = verb
      @body = body
      @headers = Request.default_headers.merge(headers)
    end

    # @return [Net::HTTP::Get, Net::HTTP::Delete, Net::HTTP::Post, Net::HTTP::Post::Multipart, Net::HTTP::Put, Net::HTTP::Put::Multipart]
    def as_net_http_request
      case verb
      when :get
        as_get
      when :delete
        as_delete
      when :post
        as_post
      when :put
        as_put
      else
        raise "Unknown HTTP verb #{verb}; supports :get, :post, :put, :delete"
      end
    end

    private

    # @return [Net::HTTP::Get]
    def as_get
      the_uri = body ? uri + URI.encode_www_form(body) : uri
      Net::HTTP::Get.new(the_uri.request_uri, headers.merge({
        'Content-Type' => 'application/x-www-form-urlencoded'
      }))
    end

    # @return [Net::HTTP::Delete]
    def as_delete
      the_uri = body ? uri + URI.encode_www_form(body) : uri
      Net::HTTP::Delete.new(the_uri.request_uri, headers.merge({
        'Content-Type' => 'application/x-www-form-urlencoded'
      }))
    end

    # @return [Net::HTTP::Post, Net::HTTP::Post::Multipart]
    def as_post
      if is_multipart
        Net::HTTP::Post::Multipart.new(uri.request_uri, body, headers)
      else
        request = Net::HTTP::Post.new(uri.request_uri, headers)
        if is_upload
          request.body_stream = body
        else
          request.body = encoded_body
        end
        request
      end
    end

    # @return [Net::HTTP::Put, Net::HTTP::Put::Multipart]
    def as_put
      if is_multipart
        Net::HTTP::Put::Multipart.new(uri.request_uri, body, headers)
      else
        request = Net::HTTP::Put.new(uri.request_uri, headers)
        if is_upload
          request.body_stream = body
        else
          request.body = encoded_body
        end
        request
      end
    end

    # @return [String, nil]
    def encoded_body
      return nil if body.nil?

      case headers['Content-Type']
      when 'application/x-www-form-urlencoded'
        URI.encode_www_form(body)
      when 'application/json'
        body.to_json
      else
        nil
      end
    end

    # @return [Boolean]
    def is_multipart
      is_upload && (body.is_a?(Hash) || body.is_a?(Array))
    end

    # @return [Boolean]
    def is_upload
      # We don't care about XML, so if we have a body and it's neither JSON nor
      #   URL-encoded, assume we're uploading files
      headers['Content-Type'] != 'application/json' &&
        headers['Content-Type'] != 'application/x-www-form-urlencoded' &&
        !body.nil?
    end
  end
end
