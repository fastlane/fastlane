require "securerandom"
module Spaceship
  # rubocop:disable Metrics/ClassLength
  class TunesClient < Spaceship::Client
    # ITunesConnectError is only thrown when iTunes Connect raises an exception
    class ITunesConnectError < BasicPreferredInfoError
    end

    # raised if the server failed to save temporarily
    class ITunesConnectTemporaryError < ITunesConnectError
    end

    attr_reader :du_client

    def initialize
      super

      @du_client = DUClient.new
    end

    class << self
      # trailer preview screenshots are required to have a specific size
      def video_preview_resolution_for(device, is_portrait)
        resolutions = {
            'iphone4' => [1136, 640],
            'iphone6' => [1334, 750],
            'iphone6Plus' => [2208, 1242],
            'ipad' => [1024, 768],
            'ipadPro' => [2732, 2048]
        }

        r = resolutions[device]
        r = [r[1], r[0]] if is_portrait
        r
      end
    end

    #####################################################
    # @!group Init and Login
    #####################################################

    def self.hostname
      "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/"
    end

    # Shows a team selection for the user in the terminal. This should not be
    # called on CI systems
    def select_team
      t_id = (ENV['FASTLANE_ITC_TEAM_ID'] || '').strip
      t_name = (ENV['FASTLANE_ITC_TEAM_NAME'] || '').strip

      if t_name.length > 0 && t_id.length.zero? # we prefer IDs over names, they are unique
        puts "Looking for iTunes Connect Team with name #{t_name}" if Spaceship::Globals.verbose?

        teams.each do |t|
          t_id = t['contentProvider']['contentProviderId'].to_s if t['contentProvider']['name'].casecmp(t_name.downcase).zero?
        end

        puts "Could not find team with name '#{t_name}', trying to fallback to default team" if t_id.length.zero?
      end

      t_id = teams.first['contentProvider']['contentProviderId'].to_s if teams.count == 1

      if t_id.length > 0
        puts "Looking for iTunes Connect Team with ID #{t_id}" if Spaceship::Globals.verbose?

        # actually set the team id here
        self.team_id = t_id
        return
      end

      # user didn't specify a team... #thisiswhywecanthavenicethings
      loop do
        puts "Multiple iTunes Connect teams found, please enter the number of the team you want to use: "
        puts "Note: to automatically choose the team, provide either the iTunes Connect Team ID, or the Team Name in your fastlane/Appfile:"
        puts "Alternatively you can pass the team name or team ID using the `FASTLANE_ITC_TEAM_ID` or `FASTLANE_ITC_TEAM_NAME` environment variable"
        first_team = teams.first["contentProvider"]
        puts ""
        puts "  itc_team_id \"#{first_team['contentProviderId']}\""
        puts ""
        puts "or"
        puts ""
        puts "  itc_team_name \"#{first_team['name']}\""
        puts ""
        teams.each_with_index do |team, i|
          puts "#{i + 1}) \"#{team['contentProvider']['name']}\" (#{team['contentProvider']['contentProviderId']})"
        end

        selected = ($stdin.gets || '').strip.to_i - 1
        team_to_use = teams[selected] if selected >= 0

        if team_to_use
          self.team_id = team_to_use['contentProvider']['contentProviderId'].to_s # actually set the team id here
          break
        end
      end
    end

    def send_login_request(user, password)
      clear_user_cached_data
      send_shared_login_request(user, password)
    end

    # rubocop:disable Metrics/PerceivedComplexity
    def handle_itc_response(raw)
      return unless raw
      return unless raw.kind_of? Hash

      data = raw['data'] || raw # sometimes it's with data, sometimes it isn't

      if data.fetch('sectionErrorKeys', []).count == 0 and
         data.fetch('sectionInfoKeys', []).count == 0 and
         data.fetch('sectionWarningKeys', []).count == 0 and
         data.fetch('validationErrors', []).count == 0

        logger.debug("Request was successful")
      end

      # We pass on the `current_language` so that the error message tells the user
      # what language the error was caused in
      handle_response_hash = lambda do |hash, current_language = nil|
        errors = []
        if hash.kind_of?(Hash)
          current_language ||= hash["language"]

          hash.each do |key, value|
            errors += handle_response_hash.call(value, current_language)

            next unless key == 'errorKeys' and value.kind_of?(Array) and value.count > 0
            # Prepend the error with the language so it's easier to understand for the user
            errors += value.collect do |current_error_message|
              current_language ? "[#{current_language}]: #{current_error_message}" : current_error_message
            end
          end
        elsif hash.kind_of? Array
          hash.each do |value|
            errors += handle_response_hash.call(value)
          end
          # else: We don't care about simple values
        end
        return errors
      end

      errors = handle_response_hash.call(data)
      errors += data.fetch('sectionErrorKeys', [])
      errors += data.fetch('validationErrors', [])

      # Sometimes there is a different kind of error in the JSON response
      # e.g. {"warn"=>nil, "error"=>["operation_failed"], "info"=>nil}
      different_error = raw.fetch('messages', {}).fetch('error', nil)
      errors << different_error if different_error

      if errors.count > 0 # they are separated by `.` by default
        # Sample `error` content: [["Forbidden"]]
        if errors.count == 1 and errors.first == "You haven't made any changes."
          # This is a special error which we really don't care about
        elsif errors.count == 1 and errors.first.include?("try again later")
          raise ITunesConnectTemporaryError.new, errors.first
        elsif errors.count == 1 and errors.first.include?("Forbidden")
          raise_insuffient_permission_error!
        else
          raise ITunesConnectError.new, errors.join(' ')
        end
      end

      puts data['sectionInfoKeys'] if data['sectionInfoKeys']
      puts data['sectionWarningKeys'] if data['sectionWarningKeys']

      return data
    end
    # rubocop:enable Metrics/PerceivedComplexity

    #####################################################
    # @!group Applications
    #####################################################

    def applications
      r = request(:get, 'ra/apps/manageyourapps/summary/v2')
      parse_response(r, 'data')['summaries']
    end

    def app_details(app_id)
      r = request(:get, "ra/apps/#{app_id}/details")
      parse_response(r, 'data')
    end

    def update_app_details!(app_id, data)
      r = request(:post) do |req|
        req.url "ra/apps/#{app_id}/details"
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end

      handle_itc_response(r.body)
    end

    # Creates a new application on iTunes Connect
    # @param name (String): The name of your app as it will appear on the App Store.
    #   This can't be longer than 255 characters.
    # @param primary_language (String): If localized app information isn't available in an
    #   App Store territory, the information from your primary language will be used instead.
    # @param version *DEPRECATED: Use `Spaceship::Tunes::Application.ensure_version!` method instead*
    #   (String): The version number is shown on the App Store and should match the one you used in Xcode.
    # @param sku (String): A unique ID for your app that is not visible on the App Store.
    # @param bundle_id (String): The bundle ID must match the one you used in Xcode. It
    #   can't be changed after you submit your first build.
    def create_application!(name: nil, primary_language: nil, version: nil, sku: nil, bundle_id: nil, bundle_id_suffix: nil, company_name: nil, platform: nil)
      puts "The `version` parameter is deprecated. Use `Spaceship::Tunes::Application.ensure_version!` method instead" if version

      # First, we need to fetch the data from Apple, which we then modify with the user's values
      primary_language ||= "English"
      platform ||= "ios"
      r = request(:get, "ra/apps/create/v2/?platformString=#{platform}")
      data = parse_response(r, 'data')

      # Now fill in the values we have
      # some values are nil, that's why there is a hash
      data['name'] = { value: name }
      data['bundleId'] = { value: bundle_id }
      data['primaryLanguage'] = { value: primary_language }
      data['primaryLocaleCode'] = { value: primary_language.to_itc_locale }
      data['vendorId'] = { value: sku }
      data['bundleIdSuffix'] = { value: bundle_id_suffix }
      data['companyName'] = { value: company_name } if company_name
      data['enabledPlatformsForCreation'] = { value: [platform] }

      data['initialPlatform'] = platform
      data['enabledPlatformsForCreation'] = { value: [platform] }

      # Now send back the modified hash
      r = request(:post) do |req|
        req.url 'ra/apps/create/v2'
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end

      data = parse_response(r, 'data')
      handle_itc_response(data)
    end

    def create_version!(app_id, version_number, platform = 'ios')
      r = request(:post) do |req|
        req.url "ra/apps/#{app_id}/platforms/#{platform}/versions/create/"
        req.body = {
          version: {
            value: version_number.to_s
          }
        }.to_json
        req.headers['Content-Type'] = 'application/json'
      end

      data = parse_response(r, 'data')
      handle_itc_response(data)
    end

    def get_resolution_center(app_id, platform)
      r = request(:get, "ra/apps/#{app_id}/platforms/#{platform}/resolutionCenter?v=latest")
      parse_response(r, 'data')
    end

    def get_ratings(app_id, platform, versionId = '', storefront = '')
      # if storefront or versionId is empty api fails
      rating_url = "ra/apps/#{app_id}/platforms/#{platform}/reviews/summary?"
      rating_url << "storefront=#{storefront}" unless storefront.empty?
      rating_url << "versionId=#{versionId}" unless versionId.empty?

      r = request(:get, rating_url)
      parse_response(r, 'data')
    end

    def get_reviews(app_id, platform, storefront, versionId = '')
      index = 0
      per_page = 100 # apple default
      all_reviews = []
      loop do
        r = request(:get, "ra/apps/#{app_id}/platforms/#{platform}/reviews?storefront=#{storefront}&versionId=#{versionId}&index=#{index}")
        all_reviews.concat(parse_response(r, 'data')['reviews'])
        if all_reviews.count < parse_response(r, 'data')['reviewCount']
          index += per_page
        else
          break
        end
      end
      all_reviews
    end

    #####################################################
    # @!group AppVersions
    #####################################################

    def app_version(app_id, is_live, platform: nil)
      raise "app_id is required" unless app_id

      # First we need to fetch the IDs for the edit / live version
      r = request(:get, "ra/apps/#{app_id}/overview")
      platforms = parse_response(r, 'data')['platforms']

      platform = Spaceship::Tunes::AppVersionCommon.find_platform(platforms, search_platform: platform)
      return nil unless platform

      version_id = Spaceship::Tunes::AppVersionCommon.find_version_id(platform, is_live)
      return nil unless version_id

      version_platform = platform['platformString']

      app_version_data(app_id, version_platform: version_platform, version_id: version_id)
    end

    def app_version_data(app_id, version_platform: nil, version_id: nil)
      raise "app_id is required" unless app_id
      raise "version_platform is required" unless version_platform
      raise "version_id is required" unless version_id

      r = request(:get, "ra/apps/#{app_id}/platforms/#{version_platform}/versions/#{version_id}")
      parse_response(r, 'data')
    end

    def update_app_version!(app_id, version_id, data)
      raise "app_id is required" unless app_id
      raise "version_id is required" unless version_id.to_i > 0

      with_tunes_retry do
        r = request(:post) do |req|
          req.url "ra/apps/#{app_id}/platforms/ios/versions/#{version_id}"
          req.body = data.to_json
          req.headers['Content-Type'] = 'application/json'
        end

        handle_itc_response(r.body)
      end
    end

    #####################################################
    # @!group Members
    #####################################################

    def members
      r = request(:get, "ra/users/itc")
      parse_response(r, 'data')["users"]
    end

    def reinvite_member(email)
      request(:post, "ra/users/itc/#{email}/resendInvitation")
    end

    def delete_member!(user_id, email)
      payload = []
      payload << {
        dsId: user_id,
        email: email
      }
      request(:post) do |req|
        req.url "ra/users/itc/delete"
        req.body = payload.to_json
        req.headers['Content-Type'] = 'application/json'
      end
    end

    def create_member!(firstname: nil, lastname: nil, email_address: nil, roles: [], apps: [])
      r = request(:get, "ra/users/itc/create")
      data = parse_response(r, 'data')

      data["user"]["firstName"] = { value: firstname }
      data["user"]["lastName"] = { value: lastname }
      data["user"]["emailAddress"] = { value: email_address }

      roles << "admin" if roles.length == 0

      data["user"]["roles"] = []
      roles.each do |role|
        # find role from template
        data["roles"].each do |template_role|
          if template_role["value"]["name"] == role
            data["user"]["roles"] << template_role
          end
        end
      end

      if apps.length == 0
        data["user"]["userSoftwares"] = { value: { grantAllSoftware: true, grantedSoftwareAdamIds: [] } }
      else
        data["user"]["userSoftwares"] = { value: { grantAllSoftware: false, grantedSoftwareAdamIds: apps } }
      end

      # send the changes back to Apple
      r = request(:post) do |req|
        req.url "ra/users/itc/create"
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      handle_itc_response(r.body)
    end

    #####################################################
    # @!group Pricing
    #####################################################

    def update_price_tier!(app_id, price_tier)
      r = request(:get, "ra/apps/#{app_id}/pricing/intervals")
      data = parse_response(r, 'data')

      first_price = (data["pricingIntervalsFieldTO"]["value"] || []).count == 0 # first price
      data["pricingIntervalsFieldTO"]["value"] ||= []
      data["pricingIntervalsFieldTO"]["value"] << {} if data["pricingIntervalsFieldTO"]["value"].count == 0
      data["pricingIntervalsFieldTO"]["value"].first["tierStem"] = price_tier.to_s

      effective_date = (first_price ? nil : Time.now.to_i * 1000)
      data["pricingIntervalsFieldTO"]["value"].first["priceTierEffectiveDate"] = effective_date
      data["pricingIntervalsFieldTO"]["value"].first["priceTierEndDate"] = nil
      data["countriesChanged"] = first_price
      data["theWorld"] = true

      if first_price # first price, need to set all countries
        data["countries"] = supported_countries.collect do |c|
          c.delete('region') # we don't care about le region
          c
        end
      end

      # send the changes back to Apple
      r = request(:post) do |req|
        req.url "ra/apps/#{app_id}/pricing/intervals"
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      handle_itc_response(r.body)
    end

    def price_tier(app_id)
      r = request(:get, "ra/apps/#{app_id}/pricing/intervals")
      data = parse_response(r, 'data')

      begin
        data["pricingIntervalsFieldTO"]["value"].first["tierStem"]
      rescue
        nil
      end
    end

    # Returns an array of all available pricing tiers
    #
    # @note Although this information is publicly available, the current spaceship implementation requires you to have a logged in client to access it
    #
    # @return [Array] the PricingTier objects (Spaceship::Tunes::PricingTier)
    # [{
    #   "tierStem": "0",
    #   "tierName": "Free",
    #   "pricingInfo": [{
    #       "country": "United States",
    #       "countryCode": "US",
    #       "currencySymbol": "$",
    #       "currencyCode": "USD",
    #       "wholesalePrice": 0.0,
    #       "retailPrice": 0.0,
    #       "fRetailPrice": "$0.00",
    #       "fWholesalePrice": "$0.00"
    #     }, {
    #     ...
    # }, {
    # ...
    def pricing_tiers
      @pricing_tiers ||= begin
        r = request(:get, 'ra/apps/pricing/matrix')
        data = parse_response(r, 'data')['pricingTiers']
        data.map { |tier| Spaceship::Tunes::PricingTier.factory(tier) }
      end
    end

    #####################################################
    # @!group Availability
    #####################################################
    # Updates the availability
    #
    # @note Although this information is publicly available, the current spaceship implementation requires you to have a logged in client to access it
    # @param app_id (String): The id of your app
    # @param availability (Availability): The availability update
    #
    # @return [Spaceship::Tunes::Availability] the new Availability
    def update_availability!(app_id, availability)
      r = request(:get, "ra/apps/#{app_id}/pricing/intervals")
      data = parse_response(r, 'data')

      data["countriesChanged"] = true
      data["countries"] = availability.territories.map { |territory| { 'code' => territory.code } }
      data["theWorld"] = availability.include_future_territories.nil? ? true : availability.include_future_territories

      # send the changes back to Apple
      r = request(:post) do |req|
        req.url "ra/apps/#{app_id}/pricing/intervals"
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      handle_itc_response(r.body)
      data = parse_response(r, 'data')
      Spaceship::Tunes::Availability.factory(data)
    end

    def availability(app_id)
      r = request(:get, "ra/apps/#{app_id}/pricing/intervals")
      data = parse_response(r, 'data')
      Spaceship::Tunes::Availability.factory(data)
    end

    # Returns an array of all supported territories
    #
    # @note Although this information is publicly available, the current spaceship implementation requires you to have a logged in client to access it
    #
    # @return [Array] the Territory objects (Spaceship::Tunes::Territory)
    def supported_territories
      data = supported_countries
      data.map { |country| Spaceship::Tunes::Territory.factory(country) }
    end

    # An array of supported countries
    # [{
    #   "code": "AL",
    #   "name": "Albania",
    #   "region": "Europe"
    # }, {
    # ...
    def supported_countries
      r = request(:get, "ra/apps/pricing/supportedCountries")
      parse_response(r, 'data')
    end

    def available_languages
      r = request(:get, "ra/apps/storePreview/regionCountryLanguage")
      response = parse_response(r, 'data')
      response.flat_map { |region| region["storeFronts"] }
              .flat_map { |storefront| storefront["supportedLocaleCodes"] }
              .uniq
    end

    #####################################################
    # @!group App Icons
    #####################################################
    # Uploads a large icon
    # @param app_version (AppVersion): The version of your app
    # @param upload_image (UploadFile): The icon to upload
    # @return [JSON] the response
    def upload_large_icon(app_version, upload_image)
      raise "app_version is required" unless app_version
      raise "upload_image is required" unless upload_image

      du_client.upload_large_icon(app_version, upload_image, content_provider_id, sso_token_for_image)
    end

    # Uploads a watch icon
    # @param app_version (AppVersion): The version of your app
    # @param upload_image (UploadFile): The icon to upload
    # @return [JSON] the response
    def upload_watch_icon(app_version, upload_image)
      raise "app_version is required" unless app_version
      raise "upload_image is required" unless upload_image

      du_client.upload_watch_icon(app_version, upload_image, content_provider_id, sso_token_for_image)
    end

    # Uploads an In-App-Purchase Review screenshot
    # @param app_id (AppId): The id of the app
    # @param upload_image (UploadFile): The icon to upload
    # @return [JSON] the response
    def upload_purchase_review_screenshot(app_id, upload_image)
      du_client.upload_purchase_review_screenshot(app_id, upload_image, content_provider_id, sso_token_for_image)
    end

    # Uploads a screenshot
    # @param app_version (AppVersion): The version of your app
    # @param upload_image (UploadFile): The image to upload
    # @param device (string): The target device
    # @param is_messages (Bool): True if the screenshot is for iMessage
    # @return [JSON] the response
    def upload_screenshot(app_version, upload_image, device, is_messages)
      raise "app_version is required" unless app_version
      raise "upload_image is required" unless upload_image
      raise "device is required" unless device

      du_client.upload_screenshot(app_version, upload_image, content_provider_id, sso_token_for_image, device, is_messages)
    end

    # Uploads an iMessage screenshot
    # @param app_version (AppVersion): The version of your app
    # @param upload_image (UploadFile): The image to upload
    # @param device (string): The target device
    # @return [JSON] the response
    def upload_messages_screenshot(app_version, upload_image, device)
      raise "app_version is required" unless app_version
      raise "upload_image is required" unless upload_image
      raise "device is required" unless device

      du_client.upload_messages_screenshot(app_version, upload_image, content_provider_id, sso_token_for_image, device)
    end

    # Uploads the transit app file
    # @param app_version (AppVersion): The version of your app
    # @param upload_file (UploadFile): The image to upload
    # @return [JSON] the response
    def upload_geojson(app_version, upload_file)
      raise "app_version is required" unless app_version
      raise "upload_file is required" unless upload_file

      du_client.upload_geojson(app_version, upload_file, content_provider_id, sso_token_for_image)
    end

    # Uploads the transit app file
    # @param app_version (AppVersion): The version of your app
    # @param upload_trailer (UploadFile): The trailer to upload
    # @return [JSON] the response
    def upload_trailer(app_version, upload_trailer)
      raise "app_version is required" unless app_version
      raise "upload_trailer is required" unless upload_trailer

      du_client.upload_trailer(app_version, upload_trailer, content_provider_id, sso_token_for_video)
    end

    # Uploads the trailer preview
    # @param app_version (AppVersion): The version of your app
    # @param upload_trailer_preview (UploadFile): The trailer preview to upload
    # @return [JSON] the response
    def upload_trailer_preview(app_version, upload_trailer_preview)
      raise "app_version is required" unless app_version
      raise "upload_trailer_preview is required" unless upload_trailer_preview

      du_client.upload_trailer_preview(app_version, upload_trailer_preview, content_provider_id, sso_token_for_image)
    end

    # Fetches the App Version Reference information from ITC
    # @return [AppVersionRef] the response
    def ref_data
      r = request(:get, '/WebObjects/iTunesConnect.woa/ra/apps/version/ref')
      data = parse_response(r, 'data')
      Spaceship::Tunes::AppVersionRef.factory(data)
    end

    # Fetches the User Detail information from ITC. This gets called often and almost never changes
    # so we cache it
    # @return [UserDetail] the response
    def user_detail_data
      @_cached_user_detail_data ||= Spaceship::Tunes::UserDetail.factory(user_details_data)
    end

    #####################################################
    # @!group CandiateBuilds
    #####################################################

    def candidate_builds(app_id, version_id)
      r = request(:get, "ra/apps/#{app_id}/versions/#{version_id}/candidateBuilds")
      parse_response(r, 'data')['builds']
    end

    #####################################################
    # @!group Build Trains
    #####################################################

    # rubocop:disable Metrics/BlockNesting
    # @param (testing_type) internal or external
    def build_trains(app_id, testing_type, tries = 5, platform: nil)
      raise "app_id is required" unless app_id
      url = "ra/apps/#{app_id}/trains/?testingType=#{testing_type}"
      url += "&platform=#{platform}" unless platform.nil?
      r = request(:get, url)
      return parse_response(r, 'data')
    rescue Spaceship::Client::UnexpectedResponse => ex
      # Build trains fail randomly very often
      # we need to catch those errors and retry
      # https://github.com/fastlane/fastlane/issues/6419
      retry_error_messages = [
        "ITC.response.error.OPERATION_FAILED",
        "Internal Server Error",
        "Service Unavailable"
      ].freeze

      if retry_error_messages.any? { |message| ex.to_s.include?(message) }
        tries -= 1
        if tries > 0
          logger.warn("Received temporary server error from iTunes Connect. Retrying the request...")
          sleep 3 unless defined? SpecHelper
          retry
        end
      end

      raise Spaceship::Client::UnexpectedResponse, "Temporary iTunes Connect error: #{ex}"
    end
    # rubocop:enable Metrics/BlockNesting

    def update_build_trains!(app_id, testing_type, data)
      raise "app_id is required" unless app_id

      # The request fails if this key is present in the data
      data.delete("dailySubmissionCountByPlatform")

      r = request(:post) do |req|
        req.url "ra/apps/#{app_id}/testingTypes/#{testing_type}/trains/"
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end

      handle_itc_response(r.body)
    end

    def remove_testflight_build_from_review!(app_id: nil, train: nil, build_number: nil, platform: 'ios')
      r = request(:post) do |req|
        req.url "ra/apps/#{app_id}/platforms/#{platform}/trains/#{train}/builds/#{build_number}/reject"
        req.body = {}.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      handle_itc_response(r.body)
    end

    # All build trains, even if there is no TestFlight
    def all_build_trains(app_id: nil, platform: 'ios')
      platform = 'ios' if platform.nil?
      r = request(:get, "ra/apps/#{app_id}/buildHistory?platform=#{platform}")
      handle_itc_response(r.body)
    end

    def all_builds_for_train(app_id: nil, train: nil, platform: 'ios')
      platform = 'ios' if platform.nil?
      r = request(:get, "ra/apps/#{app_id}/trains/#{train}/buildHistory?platform=#{platform}")
      handle_itc_response(r.body)
    end

    def build_details(app_id: nil, train: nil, build_number: nil, platform: nil)
      r = request(:get, "ra/apps/#{app_id}/platforms/#{platform || 'ios'}/trains/#{train}/builds/#{build_number}/details")
      handle_itc_response(r.body)
    end

    def update_build_information!(app_id: nil,
                                  train: nil,
                                  build_number: nil,

                                  # optional:
                                  whats_new: nil,
                                  description: nil,
                                  feedback_email: nil,
                                  platform: 'ios')
      url = "ra/apps/#{app_id}/platforms/#{platform}/trains/#{train}/builds/#{build_number}/testInformation"

      build_info = get_build_info_for_review(app_id: app_id, train: train, build_number: build_number, platform: platform)
      build_info["details"].each do |current|
        current["whatsNew"]["value"] = whats_new if whats_new
        current["description"]["value"] = description if description
        current["feedbackEmail"]["value"] = feedback_email if feedback_email
      end

      review_user_name = build_info['reviewUserName']['value']
      review_password = build_info['reviewPassword']['value']
      build_info['reviewAccountRequired']['value'] = (review_user_name.to_s + review_password.to_s).length > 0

      # Now send everything back to iTC
      r = request(:post) do |req| # same URL, but a POST request
        req.url url
        req.body = build_info.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      handle_itc_response(r.body)
    end

    # rubocop:disable Metrics/ParameterLists
    def submit_testflight_build_for_review!(app_id: nil, train: nil, build_number: nil, platform: 'ios',
                                            # Required Metadata:
                                            changelog: nil,
                                            description: nil,
                                            feedback_email: nil,
                                            marketing_url: nil,
                                            first_name: nil,
                                            last_name: nil,
                                            review_email: nil,
                                            phone_number: nil,
                                            significant_change: false,

                                            # Optional Metadata:
                                            privacy_policy_url: nil,
                                            review_user_name: nil,
                                            review_password: nil,
                                            review_notes: nil,
                                            encryption: false,
                                            encryption_updated: false,
                                            is_exempt: false,
                                            proprietary: false,
                                            third_party: false)

      build_info = get_build_info_for_review(app_id: app_id, train: train, build_number: build_number, platform: platform)
      # Now fill in the values provided by the user

      # First the localised values:
      build_info['details'].each do |current|
        current['whatsNew']['value'] = changelog if changelog
        current['description']['value'] = description if description
        current['feedbackEmail']['value'] = feedback_email if feedback_email
        current['marketingUrl']['value'] = marketing_url if marketing_url
        current['privacyPolicyUrl']['value'] = privacy_policy_url if privacy_policy_url
        current['pageLanguageValue'] = current['language'] # There is no valid reason why we need this, only iTC being iTC
      end

      review_info = {
        "significantChange" => {
          "value" => significant_change
        },
        "buildTestInformationTO" => build_info,
        "exportComplianceTO" => {
          "usesEncryption" => {
            "value" => encryption
          },
          "encryptionUpdated" => {
            "value" => encryption_updated
          },
          "isExempt" => {
            "value" => is_exempt
          },
          "containsProprietaryCryptography" => {
            "value" => proprietary
          },
          "containsThirdPartyCryptography" => {
            "value" => third_party
          }
        }
      }

      r = request(:post) do |req| # same URL, but a POST request
        req.url "ra/apps/#{app_id}/platforms/#{platform}/trains/#{train}/builds/#{build_number}/review/submit"

        req.body = review_info.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      handle_itc_response(r.body)
    end
    # rubocop:enable Metrics/ParameterLists

    def get_build_info_for_review(app_id: nil, train: nil, build_number: nil, platform: 'ios')
      url = "ra/apps/#{app_id}/platforms/#{platform}/trains/#{train}/builds/#{build_number}/testInformation"
      r = request(:get) do |req|
        req.url url
        req.headers['Content-Type'] = 'application/json'
      end
      handle_itc_response(r.body)

      r.body['data']
    end

    #####################################################
    # @!group Submit for Review
    #####################################################

    def prepare_app_submissions(app_id, version)
      raise "app_id is required" unless app_id
      raise "version is required" unless version

      r = request(:get) do |req|
        req.url "ra/apps/#{app_id}/versions/#{version}/submit/summary"
        req.headers['Content-Type'] = 'application/json'
      end

      handle_itc_response(r.body)
      parse_response(r, 'data')
    end

    def send_app_submission(app_id, data)
      raise "app_id is required" unless app_id

      # ra/apps/1039164429/version/submit/complete
      r = request(:post) do |req|
        req.url "ra/apps/#{app_id}/version/submit/complete"
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end

      handle_itc_response(r.body)

      if r.body.fetch('messages').fetch('info').last == "Successful POST"
        # success
      else
        raise "Something went wrong when submitting the app for review. Make sure to pass valid options to submit your app for review"
      end

      parse_response(r, 'data')
    end

    #####################################################
    # @!group release
    #####################################################

    def release!(app_id, version)
      raise "app_id is required" unless app_id
      raise "version is required" unless version

      r = request(:post) do |req|
        req.url "ra/apps/#{app_id}/versions/#{version}/releaseToStore"
        req.headers['Content-Type'] = 'application/json'
        req.body = app_id.to_s
      end

      handle_itc_response(r.body)
      parse_response(r, 'data')
    end

    #####################################################
    # @!group in-app-purchases
    #####################################################

    # Returns list of all available In-App-Purchases
    def iaps(app_id: nil)
      r = request(:get, "ra/apps/#{app_id}/iaps")
      return r.body["data"]
    end

    # Returns list of all available Families
    def iap_families(app_id: nil)
      r = request(:get, "ra/apps/#{app_id}/iaps/families")
      return r.body["data"]
    end

    # Deletes a In-App-Purchases
    def delete_iap!(app_id: nil, purchase_id: nil)
      r = request(:delete, "ra/apps/#{app_id}/iaps/#{purchase_id}")
      handle_itc_response(r)
    end

    # Loads the full In-App-Purchases
    def load_iap(app_id: nil, purchase_id: nil)
      r = request(:get, "ra/apps/#{app_id}/iaps/#{purchase_id}")
      parse_response(r, 'data')
    end

    # Loads the full In-App-Purchases-Family
    def load_iap_family(app_id: nil, family_id: nil)
      r = request(:get, "ra/apps/#{app_id}/iaps/family/#{family_id}")
      parse_response(r, 'data')
    end

    # Loads the full In-App-Purchases-Pricing-Matrix
    #   note: the matrix is the same for any app_id
    #
    # @param app_id (String) The Apple ID of any app
    # @return ([Spaceship::Tunes::IAPSubscriptionPricingTier]) An array of pricing tiers
    def subscription_pricing_tiers(app_id)
      @subscription_pricing_tiers ||= begin
        r = request(:get, "ra/apps/#{app_id}/iaps/pricing/matrix/recurring")
        data = parse_response(r, "data")["pricingTiers"]
        data.map { |tier| Spaceship::Tunes::IAPSubscriptionPricingTier.factory(tier) }
      end
    end

    # updates an In-App-Purchases-Family
    def update_iap_family!(app_id: nil, family_id: nil, data: nil)
      with_tunes_retry do
        r = request(:put) do |req|
          req.url "ra/apps/#{app_id}/iaps/family/#{family_id}/"
          req.body = data.to_json
          req.headers['Content-Type'] = 'application/json'
        end
        handle_itc_response(r.body)
      end
    end

    # updates an In-App-Purchases
    def update_iap!(app_id: nil, purchase_id: nil, data: nil)
      with_tunes_retry do
        r = request(:put) do |req|
          req.url "ra/apps/#{app_id}/iaps/#{purchase_id}"
          req.body = data.to_json
          req.headers['Content-Type'] = 'application/json'
        end
        handle_itc_response(r.body)
      end
    end

    def create_iap_family(app_id: nil, name: nil, product_id: nil, reference_name: nil, versions: [])
      r = request(:get, "ra/apps/#{app_id}/iaps/family/template")
      data = parse_response(r, 'data')

      data['activeAddOns'][0]['productId'] = { value: product_id }
      data['activeAddOns'][0]['referenceName'] = { value: reference_name }
      data['name'] = { value: name }
      data["details"]["value"] = versions

      r = request(:post) do |req|
        req.url "ra/apps/#{app_id}/iaps/family/"
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      handle_itc_response(r.body)
    end

    # returns pricing goal array
    def iap_subscription_pricing_target(app_id: nil, purchase_id: nil, currency: nil, tier: nil)
      r = request(:get, "ra/apps/#{app_id}/iaps/#{purchase_id}/pricing/equalize/#{currency}/#{tier}")
      parse_response(r, 'data')
    end

    # Creates an In-App-Purchases
    def create_iap!(app_id: nil, type: nil, versions: nil, reference_name: nil, product_id: nil, cleared_for_sale: true, review_notes: nil, review_screenshot: nil, pricing_intervals: nil, family_id: nil, subscription_duration: nil, subscription_free_trial: nil)
      # Load IAP Template based on Type
      type ||= "consumable"
      r = request(:get, "ra/apps/#{app_id}/iaps/#{type}/template")
      data = parse_response(r, 'data')

      # Now fill in the values we have
      # some values are nil, that's why there is a hash
      data['familyId'] = family_id.to_s if family_id
      data['productId'] = { value: product_id }
      data['referenceName'] = { value: reference_name }
      data['clearedForSale'] = { value: cleared_for_sale }

      data['pricingDurationType'] = { value: subscription_duration } if subscription_duration
      data['freeTrialDurationType'] = { value: subscription_free_trial } if subscription_free_trial

      # pricing tier
      if pricing_intervals
        data['pricingIntervals'] = []
        pricing_intervals.each do |interval|
          data['pricingIntervals'] << {
              value: {
                  country: interval[:country] || "WW",
                  tierStem: interval[:tier].to_s,
                  priceTierEndDate: interval[:end_date],
                  priceTierEffectiveDate: interval[:begin_date]
                }
          }
        end
      end

      versions_array = []
      versions.each do |k, v|
        versions_array << {
                  value: {
                    description: { value: v[:description] },
                    name: { value: v[:name] },
                    localeCode: k.to_s
                  }
        }
      end
      data["versions"][0]["details"]["value"] = versions_array
      data['versions'][0]["reviewNotes"] = { value: review_notes }

      if review_screenshot
        # Upload Screenshot:
        upload_file = UploadFile.from_path review_screenshot
        screenshot_data = upload_purchase_review_screenshot(app_id, upload_file)
        new_screenshot = {
          "value" => {
            "assetToken" => screenshot_data["token"],
            "sortOrder" => 0,
            "type" => "SortedScreenShot",
            "originalFileName" => upload_file.file_name,
            "size" => screenshot_data["length"],
            "height" => screenshot_data["height"],
            "width" => screenshot_data["width"],
            "checksum" => screenshot_data["md5"]
          }
        }

        data["versions"][0]["reviewScreenshot"] = new_screenshot
      end

      # Now send back the modified hash
      r = request(:post) do |req|
        req.url "ra/apps/#{app_id}/iaps"
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      handle_itc_response(r.body)
    end

    #####################################################
    # @!group Testers
    #####################################################
    def testers(tester)
      url = tester.url[:index]
      r = request(:get, url)
      parse_response(r, 'data')['testers']
    end

    def testers_by_app(tester, app_id)
      url = tester.url(app_id)[:index_by_app]
      r = request(:get, url)
      parse_response(r, 'data')['users']
    end

    # Returns a list of available testing groups
    # e.g.
    #   {"b6f65dbd-c845-4d91-bc39-0b661d608970" => "Boarding",
    #    "70402368-9deb-409f-9a26-bb3f215dfee3" => "Automatic"}
    def groups
      return @cached_groups if @cached_groups
      r = request(:get, '/WebObjects/iTunesConnect.woa/ra/users/pre/ext')
      @cached_groups = parse_response(r, 'data')['groups']
    end

    def create_tester!(tester: nil, email: nil, first_name: nil, last_name: nil, groups: nil)
      url = tester.url[:create]
      raise "Action not provided for this tester type." unless url

      tester_data = {
        emailAddress: {
          value: email
        },
        firstName: {
          value: first_name || ""
        },
        lastName: {
          value: last_name || ""
        },
        testing: {
          value: true
        }
      }

      if groups
        tester_data[:groups] = groups.map do |group_name_or_group_id|
          if self.groups.value?(group_name_or_group_id)
            # This is an existing group, let's use that, the user specified the group name
            group_name = group_name_or_group_id
            group_id = self.groups.key(group_name_or_group_id)
          elsif self.groups.key?(group_name_or_group_id)
            # This is an existing group, let's use that, the user specified the group ID
            group_name = self.groups[group_name_or_group_id]
            group_id = group_name_or_group_id
          else
            group_name = group_name_or_group_id
            group_id = nil # this is expected by the iTC API
          end

          {
            "id" => group_id,
            "name" => {
              "value" => group_name
            }
          }
        end
      end

      data = { testers: [tester_data] }

      r = request(:post) do |req|
        req.url url
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end

      data = parse_response(r, 'data')['testers']
      handle_itc_response(data) || data[0]
    end

    def delete_tester!(tester)
      url = tester.class.url[:delete]
      raise "Action not provided for this tester type." unless url

      data = [
        {
          emailAddress: {
            value: tester.email
          },
          firstName: {
            value: tester.first_name
          },
          lastName: {
            value: tester.last_name
          },
          testing: {
            value: false
          },
          userName: tester.email,
          testerId: tester.tester_id
        }
      ]

      r = request(:post) do |req|
        req.url url
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end

      data = parse_response(r, 'data')['testers']
      handle_itc_response(data) || data[0]
    end

    def add_tester_to_app!(tester, app_id)
      update_tester_from_app!(tester, app_id, true)
    end

    def remove_tester_from_app!(tester, app_id)
      update_tester_from_app!(tester, app_id, false)
    end

    #####################################################
    # @!group Sandbox Testers
    #####################################################
    def sandbox_testers(tester_class)
      url = tester_class.url[:index]
      r = request(:get, url)
      parse_response(r, 'data')
    end

    def create_sandbox_tester!(tester_class: nil, email: nil, password: nil, first_name: nil, last_name: nil, country: nil)
      url = tester_class.url[:create]
      r = request(:post) do |req|
        req.url url
        req.body = {
          user: {
            emailAddress: { value: email },
            password: { value: password },
            confirmPassword: { value: password },
            firstName: { value: first_name },
            lastName: { value: last_name },
            storeFront: { value: country },
            birthDay: { value: 1 },
            birthMonth: { value: 1 },
            secretQuestion: { value: SecureRandom.hex },
            secretAnswer: { value: SecureRandom.hex },
            sandboxAccount: nil
          }
        }.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      parse_response(r, 'data')['user']
    end

    def delete_sandbox_testers!(tester_class, emails)
      url = tester_class.url[:delete]
      request(:post) do |req|
        req.url url
        req.body = emails.map do |email|
          {
            emailAddress: {
              value: email
            }
          }
        end.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      true
    end

    #####################################################
    # @!group State History
    #####################################################
    def versions_history(app_id, platform)
      r = request(:get, "ra/apps/#{app_id}/stateHistory?platform=#{platform}")
      parse_response(r, 'data')['versions']
    end

    def version_states_history(app_id, platform, version_id)
      r = request(:get, "ra/apps/#{app_id}/versions/#{version_id}/stateHistory?platform=#{platform}")
      parse_response(r, 'data')
    end

    #####################################################
    # @!group Promo codes
    #####################################################
    def app_promocodes(app_id: nil)
      r = request(:get, "ra/apps/#{app_id}/promocodes/versions")
      parse_response(r, 'data')['versions']
    end

    def generate_app_version_promocodes!(app_id: nil, version_id: nil, quantity: nil)
      data = {
        numberOfCodes: { value: quantity },
        agreedToContract: { value: true }
      }
      url = "ra/apps/#{app_id}/promocodes/versions/#{version_id}"
      r = request(:post) do |req|
        req.url url
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      parse_response(r, 'data')
    end

    def app_promocodes_history(app_id: nil)
      r = request(:get, "ra/apps/#{app_id}/promocodes/history")
      parse_response(r, 'data')['requests']
    end

    #####################################################
    # @!group reject
    #####################################################

    def reject!(app_id, version)
      raise "app_id is required" unless app_id
      raise "version is required" unless version

      r = request(:post) do |req|
        req.url "ra/apps/#{app_id}/versions/#{version}/reject"
        req.headers['Content-Type'] = 'application/json'
        req.body = app_id.to_s
      end

      handle_itc_response(r.body)
      parse_response(r, 'data')
    end

    private

    def with_tunes_retry(tries = 5, &_block)
      return yield
    rescue Spaceship::TunesClient::ITunesConnectTemporaryError => ex
      unless (tries -= 1).zero?
        msg = "iTunes Connect temporary error received: '#{ex.message}'. Retrying after 60 seconds (remaining: #{tries})..."
        puts msg
        logger.warn msg
        sleep 60 unless defined? SpecHelper # unless FastlaneCore::Helper.is_test?
        retry
      end
      raise ex # re-raise the exception
    end

    def clear_user_cached_data
      @content_provider_id = nil
      @sso_token_for_image = nil
      @sso_token_for_video = nil
    end

    # the contentProviderIr found in the UserDetail instance
    def content_provider_id
      @content_provider_id ||= user_detail_data.content_provider_id
    end

    # the ssoTokenForImage found in the AppVersionRef instance
    def sso_token_for_image
      @sso_token_for_image ||= ref_data.sso_token_for_image
    end

    # the ssoTokenForVideo found in the AppVersionRef instance
    def sso_token_for_video
      @sso_token_for_video ||= ref_data.sso_token_for_video
    end

    def update_tester_from_app!(tester, app_id, testing)
      url = tester.class.url(app_id)[:update_by_app]
      data = {
        users: [
          {
            emailAddress: {
              value: tester.email
            },
            firstName: {
              value: tester.first_name
            },
            lastName: {
              value: tester.last_name
            },
            testing: {
              value: testing
            }
          }
        ]
      }

      r = request(:post) do |req|
        req.url url
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end

      data = parse_response(r, 'data')
      handle_itc_response(data)
    end
  end
  # rubocop:enable Metrics/ClassLength
end
