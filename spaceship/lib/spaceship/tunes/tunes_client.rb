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

    # @return (Array) A list of all available teams
    def teams
      return @teams if @teams
      r = request(:get, "ra/user/detail")
      @teams = parse_response(r, 'data')['associatedAccounts'].sort_by do |team|
        [
          team['contentProvider']['name'],
          team['contentProvider']['contentProviderId']
        ]
      end
    end

    # @return (String) The currently selected Team ID
    def team_id
      return @current_team_id if @current_team_id

      if teams.count > 1
        puts "The current user is in #{teams.count} teams. Pass a team ID or call `select_team` to choose a team. Using the first one for now."
      end
      @current_team_id ||= teams[0]['contentProvider']['contentProviderId']
    end

    # Set a new team ID which will be used from now on
    def team_id=(team_id)
      # First, we verify the team actually exists, because otherwise iTC would return the
      # following confusing error message
      #
      #     invalid content provider id
      #
      available_teams = teams.collect do |team|
        (team["contentProvider"] || {})["contentProviderId"]
      end

      result = available_teams.find do |available_team_id|
        team_id.to_s == available_team_id.to_s
      end

      unless result
        raise ITunesConnectError.new, "Could not set team ID to '#{team_id}', only found the following available teams: #{available_teams.join(', ')}"
      end

      response = request(:post) do |req|
        req.url "ra/v1/session/webSession"
        req.body = {
          contentProviderId: team_id,
          dsId: user_detail_data.ds_id # https://github.com/fastlane/fastlane/issues/6711
        }.to_json
        req.headers['Content-Type'] = 'application/json'
      end

      handle_itc_response(response.body)

      @current_team_id = team_id
    end

    # Shows a team selection for the user in the terminal. This should not be
    # called on CI systems
    def select_team
      t_id = (ENV['FASTLANE_ITC_TEAM_ID'] || '').strip
      t_name = (ENV['FASTLANE_ITC_TEAM_NAME'] || '').strip

      if t_name.length > 0 && t_id.length.zero? # we prefer IDs over names, they are unique
        puts "Looking for iTunes Connect Team with name #{t_name}" if $verbose

        teams.each do |t|
          t_id = t['contentProvider']['contentProviderId'].to_s if t['contentProvider']['name'].casecmp(t_name.downcase).zero?
        end

        puts "Could not find team with name '#{t_name}', trying to fallback to default team" if t_id.length.zero?
      end

      t_id = teams.first['contentProvider']['contentProviderId'].to_s if teams.count == 1

      if t_id.length > 0
        puts "Looking for iTunes Connect Team with ID #{t_id}" if $verbose

        # actually set the team id here
        self.team_id = t_id
        return
      end

      # user didn't specify a team... #thisiswhywecanthavenicethings
      loop do
        puts "Multiple iTunes Connect teams found, please enter the number of the team you want to use: "
        puts "Note: to automatically choose the team, provide either the iTunes Connect Team ID, or the Team Name in your fastlane/Appfile:"
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

    # @return (Hash) Fetches all information of the currently used team
    def team_information
      teams.find do |t|
        t['teamId'] == team_id
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
        if errors.count == 1 and errors.first == "You haven't made any changes."
          # This is a special error which we really don't care about
        elsif errors.count == 1 and errors.first.include?("try again later")
          raise ITunesConnectTemporaryError.new, errors.first
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
    # @param version (String): The version number is shown on the App Store and should
    #   match the one you used in Xcode.
    # @param sku (String): A unique ID for your app that is not visible on the App Store.
    # @param bundle_id (String): The bundle ID must match the one you used in Xcode. It
    #   can't be changed after you submit your first build.
    def create_application!(name: nil, primary_language: nil, version: nil, sku: nil, bundle_id: nil, bundle_id_suffix: nil, company_name: nil)
      # First, we need to fetch the data from Apple, which we then modify with the user's values
      app_type = 'ios'
      r = request(:get, "ra/apps/create/v2/?platformString=#{app_type}")
      data = parse_response(r, 'data')

      # Now fill in the values we have
      # some values are nil, that's why there is a hash
      data['versionString'] = { value: version }
      data['name'] = { value: name }
      data['bundleId'] = { value: bundle_id }
      data['primaryLanguage'] = { value: primary_language || 'English' }
      data['vendorId'] = { value: sku }
      data['bundleIdSuffix'] = { value: bundle_id_suffix }
      data['companyName'] = { value: company_name } if company_name
      data['enabledPlatformsForCreation'] = { value: [app_type] }

      data['initialPlatform'] = app_type
      data['enabledPlatformsForCreation'] = { value: [app_type] }

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

    def get_rating_summary(app_id, platform, versionId = '')
      r = request(:get, "ra/apps/#{app_id}/reviews/summary?platform=#{platform}&versionId=#{versionId}")
      parse_response(r, 'data')
    end

    def get_reviews(app_id, platform, storefront, versionId = '')
      r = request(:get, "ra/apps/#{app_id}/reviews?platform=#{platform}&storefront=#{storefront}&versionId=#{versionId}")
      parse_response(r, 'data')['reviews']
    end

    #####################################################
    # @!group AppVersions
    #####################################################

    def app_version(app_id, is_live)
      raise "app_id is required" unless app_id

      # First we need to fetch the IDs for the edit / live version
      r = request(:get, "ra/apps/#{app_id}/overview")
      platforms = parse_response(r, 'data')['platforms']

      platform = Spaceship::Tunes::AppVersionCommon.find_platform(platforms)
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
      r = request(:get, 'ra/apps/pricing/matrix')
      data = parse_response(r, 'data')['pricingTiers']
      data.map { |tier| Spaceship::Tunes::PricingTier.factory(tier) }
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

    # Uploads a screenshot
    # @param app_version (AppVersion): The version of your app
    # @param upload_image (UploadFile): The image to upload
    # @param device (string): The target device
    # @return [JSON] the response
    def upload_screenshot(app_version, upload_image, device)
      raise "app_version is required" unless app_version
      raise "upload_image is required" unless upload_image
      raise "device is required" unless device

      du_client.upload_screenshot(app_version, upload_image, content_provider_id, sso_token_for_image, device)
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
      return @cached if @cached
      r = request(:get, '/WebObjects/iTunesConnect.woa/ra/user/detail')
      data = parse_response(r, 'data')
      @cached = Spaceship::Tunes::UserDetail.factory(data)
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

    # @param (testing_type) internal or external
    def build_trains(app_id, testing_type)
      raise "app_id is required" unless app_id
      r = request(:get, "ra/apps/#{app_id}/trains/?testingType=#{testing_type}")
      parse_response(r, 'data')
    end

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
    def all_build_trains(app_id: nil, platform: nil)
      r = request(:get, "ra/apps/#{app_id}/buildHistory?platform=#{platform || 'ios'}")
      handle_itc_response(r.body)
    end

    def all_builds_for_train(app_id: nil, train: nil, platform: nil)
      r = request(:get, "ra/apps/#{app_id}/trains/#{train}/buildHistory?platform=#{platform || 'ios'}")
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
        tester_data[:groups] = groups.map { |x| { "id" => x } }
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

    private

    def with_tunes_retry(tries = 5, &_block)
      return yield
    rescue Spaceship::TunesClient::ITunesConnectTemporaryError => ex
      unless (tries -= 1).zero?
        msg = "ITC temporary save error received: '#{ex.message}'. Retrying after 60 seconds (remaining: #{tries})..."
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
