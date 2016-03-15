module Spaceship
  # rubocop:disable Metrics/ClassLength
  class TunesClient < Spaceship::Client
    # ITunesConnectError is only thrown when iTunes Connect raises an exception
    class ITunesConnectError < StandardError
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
      @teams = parse_response(r, 'data')['associatedAccounts']
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
      response = request(:post) do |req|
        req.url "ra/v1/session/webSession"
        req.body = { contentProviderId: team_id }.to_json
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

      if t_name.length > 0
        teams.each do |t|
          t_id = t['contentProvider']['contentProviderId'].to_s if t['contentProvider']['name'].casecmp(t_name.downcase).zero?
        end
      end

      t_id = teams.first['contentProvider']['contentProviderId'].to_s if teams.count == 1

      if t_id.length > 0
        # actually set the team id here
        self.team_id = t_id
        return
      end

      # user didn't specify a team... #thisiswhywecanthavenicethings
      loop do
        puts "Multiple iTunes Connect teams found, please enter the number of the team you want to use: "
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

    def service_key
      return @service_key if @service_key
      # We need a service key from a JS file to properly auth
      js = request(:get, "https://itunesconnect.apple.com/itc/static-resources/controllers/login_cntrl.js")
      @service_key ||= js.body.match(/itcServiceKey = '(.*)'/)[1]
    end

    def send_login_request(user, password)
      clear_user_cached_data

      data = {
        accountName: user,
        password: password,
        rememberMe: true
      }

      begin
        response = request(:post) do |req|
          req.url "https://idmsa.apple.com/appleauth/auth/signin?widgetKey=#{service_key}"
          req.body = data.to_json
          req.headers['Content-Type'] = 'application/json'
          req.headers['X-Requested-With'] = 'XMLHttpRequest'
          req.headers['Accept'] = 'application/json, text/javascript'
        end
      rescue UnauthorizedAccessError
        raise InvalidUserCredentialsError.new, "Invalid username and password combination. Used '#{user}' as the username."
      end

      # get woinst, wois, and itctx cookie values
      request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/wa/route?noext")
      request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa")

      case response.status
      when 403
        raise InvalidUserCredentialsError.new, "Invalid username and password combination. Used '#{user}' as the username."
      when 200
        return response
      else
        if response["Location"] == "/auth" # redirect to 2 step auth page
          raise "spaceship / fastlane doesn't support 2 step enabled accounts yet. Please temporary disable 2 step verification until spaceship was updated."
        elsif (response.body || "").include?('invalid="true"')
          # User Credentials are wrong
          raise InvalidUserCredentialsError.new, "Invalid username and password combination. Used '#{user}' as the username."
        elsif (response['Set-Cookie'] || "").include?("itctx")
          raise "Looks like your Apple ID is not enabled for iTunes Connect, make sure to be able to login online"
        else
          info = [response.body, response['Set-Cookie']]
          raise ITunesConnectError.new, info.join("\n")
        end
      end
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def handle_itc_response(raw)
      return unless raw
      return unless raw.kind_of? Hash

      data = raw['data'] || raw # sometimes it's with data, sometimes it isn't

      if data.fetch('sectionErrorKeys', []).count == 0 and
         data.fetch('sectionInfoKeys', []).count == 0 and
         data.fetch('sectionWarningKeys', []).count == 0

        logger.debug("Request was successful")
      end

      handle_response_hash = lambda do |hash|
        errors = []
        if hash.kind_of? Hash
          hash.each do |key, value|
            errors += handle_response_hash.call(value)

            if key == 'errorKeys' and value.kind_of? Array and value.count > 0
              errors += value
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
      errors += data.fetch('sectionErrorKeys') if data['sectionErrorKeys']

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
    # rubocop:enable Metrics/CyclomaticComplexity
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
      data['newApp']['name'] = { value: name }
      data['newApp']['bundleId']['value'] = bundle_id
      data['newApp']['primaryLanguage']['value'] = primary_language || 'English'
      data['newApp']['vendorId'] = { value: sku }
      data['newApp']['bundleIdSuffix']['value'] = bundle_id_suffix
      data['companyName']['value'] = company_name if company_name
      data['newApp']['appType'] = app_type

      data['initialPlatform'] = app_type
      data['enabledPlatformsForCreation']['value'] = [app_type]

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

    def app_version_data(app_id, version_platform: nil, version_id:nil)
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
      @cached ||= Spaceship::Tunes::UserDetail.factory(data)
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
    def all_build_trains(app_id: nil)
      r = request(:get, "ra/apps/#{app_id}/buildHistory?platform=ios")
      handle_itc_response(r.body)
    end

    def all_builds_for_train(app_id: nil, train: nil)
      r = request(:get, "ra/apps/#{app_id}/trains/#{train}/buildHistory?platform=ios")
      handle_itc_response(r.body)
    end

    def build_details(app_id: nil, train: nil, build_number: nil)
      r = request(:get, "ra/apps/#{app_id}/platforms/ios/trains/#{train}/builds/#{build_number}/details")
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
      r = request(:get) do |req|
        req.url url
        req.headers['Content-Type'] = 'application/json'
      end
      handle_itc_response(r.body)

      build_info = r.body['data']
      build_info["details"].each do |current|
        current["whatsNew"]["value"] = whats_new if whats_new
        current["description"]["value"] = description if description
        current["feedbackEmail"]["value"] = feedback_email if feedback_email
      end

      # Now send everything back to iTC
      r = request(:post) do |req| # same URL, but a POST request
        req.url url
        req.body = build_info.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      handle_itc_response(r.body)
    end

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
                                            encryption: false)

      build_info = get_build_info_for_review(app_id: app_id, train: train, build_number: build_number, platform: platform)
      # Now fill in the values provided by the user

      # First the localised values:
      build_info['testInfo']['details'].each do |current|
        current['whatsNew']['value'] = changelog if changelog
        current['description']['value'] = description if description
        current['feedbackEmail']['value'] = feedback_email if feedback_email
        current['marketingUrl']['value'] = marketing_url if marketing_url
        current['privacyPolicyUrl']['value'] = privacy_policy_url if privacy_policy_url
        current['pageLanguageValue'] = current['language'] # There is no valid reason why we need this, only iTC being iTC
      end
      build_info['significantChange'] ||= {}
      build_info['significantChange']['value'] = significant_change
      build_info['testInfo']['reviewFirstName']['value'] = first_name if first_name
      build_info['testInfo']['reviewLastName']['value'] = last_name if last_name
      build_info['testInfo']['reviewPhone']['value'] = phone_number if phone_number
      build_info['testInfo']['reviewEmail']['value'] = review_email if review_email
      build_info['testInfo']['reviewUserName']['value'] = review_user_name if review_user_name
      build_info['testInfo']['reviewPassword']['value'] = review_password if review_password

      r = request(:post) do |req| # same URL, but a POST request
        req.url "ra/apps/#{app_id}/platforms/#{platform}/trains/#{train}/builds/#{build_number}/submit/start"

        req.body = build_info.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      handle_itc_response(r.body)

      encryption_info = r.body['data']
      update_encryption_compliance(app_id: app_id,
                                   train: train,
                                   build_number: build_number,
                                   platform: platform,
                                   encryption_info: encryption_info,
                                   encryption: encryption)
    end

    def get_build_info_for_review(app_id: nil, train: nil, build_number: nil, platform: 'ios')
      r = request(:get) do |req|
        req.url "ra/apps/#{app_id}/platforms/#{platform}/trains/#{train}/builds/#{build_number}/submit/start"
        req.headers['Content-Type'] = 'application/json'
      end
      handle_itc_response(r.body)

      r.body['data']
    end

    def update_encryption_compliance(app_id: nil, train: nil, build_number: nil, platform: 'ios', encryption_info: nil, encryption: nil, is_exempt: true, proprietary: false, third_party: false)
      return unless encryption_info['exportComplianceRequired']
      # only sometimes this is required

      encryption_info['usesEncryption']['value'] = encryption
      encryption_info['encryptionUpdated'] ||= {}
      encryption_info['encryptionUpdated']['value'] = encryption
      encryption_info['isExempt']['value'] = is_exempt
      encryption_info['containsProprietaryCryptography']['value'] = proprietary
      encryption_info['containsThirdPartyCryptography']['value'] = third_party

      r = request(:post) do |req|
        req.url "ra/apps/#{app_id}/platforms/#{platform}/trains/#{train}/builds/#{build_number}/submit/complete"
        req.body = encryption_info.to_json
        req.headers['Content-Type'] = 'application/json'
      end

      handle_itc_response(r.body)
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

    def create_tester!(tester: nil, email: nil, first_name: nil, last_name: nil)
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
