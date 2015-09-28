module Spaceship
  # rubocop:disable Metrics/ClassLength
  class TunesClient < Spaceship::Client
    # ITunesConnectError is only thrown when iTunes Connect raises an exception
    class ITunesConnectError < StandardError
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
            'ipad' => [1024, 768]
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

    # Fetches the latest login URL from iTunes Connect
    def login_url
      cache_path = "/tmp/spaceship_itc_login_url.txt"
      begin
        cached = File.read(cache_path)
      rescue Errno::ENOENT
      end
      return cached if cached

      host = "https://itunesconnect.apple.com"
      begin
        url = host + request(:get, self.class.hostname).body.match(%r{action="(/WebObjects/iTunesConnect.woa/wo/.*)"})[1]
        raise "" unless url.length > 0

        File.write(cache_path, url)
        return url
      rescue => ex
        puts ex
        raise "Could not fetch the login URL from iTunes Connect, the server might be down"
      end
    end

    def send_login_request(user, password)
      response = request(:post, login_url, {
        theAccountName: user,
        theAccountPW: password
      })

      if response['Set-Cookie'] =~ /myacinfo=(\w+);/
        # To use the session properly we'll need the following cookies:
        #  - myacinfo
        #  - woinst
        #  - wosid
        #  - itctx
        begin
          re = response['Set-Cookie']

          to_use = [
            "myacinfo=" + re.match(/myacinfo=([^;]*)/)[1],
            "woinst=" + re.match(/woinst=([^;]*)/)[1],
            "itctx=" + re.match(/itctx=([^;]*)/)[1],
            "wosid=" + re.match(/wosid=([^;]*)/)[1]
          ]

          @cookie = to_use.join(';')
        rescue
          raise ITunesConnectError.new, [response.body, response['Set-Cookie']].join("\n")
        end

        return @client
      else
        if (response.body || "").include?("You have successfully signed out")
          # User Credentials are wrong
          raise InvalidUserCredentialsError.new, "Invalid username and password combination. Used '#{user}' as the username."
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

    def create_version!(app_id, version_number)
      r = request(:post) do |req|
        req.url "ra/apps/#{app_id}/platforms/ios/versions/create/"
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

    def get_resolution_center(app_id)
      r = request(:get, "ra/apps/#{app_id}/resolutionCenter?v=latest")
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

      platforms = platforms.first # That won't work for mac apps

      version = platforms[(is_live ? 'deliverableVersion' : 'inFlightVersion')]
      return nil unless version
      version_id = version['id']

      r = request(:get, "ra/apps/#{app_id}/platforms/ios/versions/#{version_id}")
      parse_response(r, 'data')
    end

    def update_app_version!(app_id, version_id, data)
      raise "app_id is required" unless app_id
      raise "version_id is required" unless version_id.to_i > 0

      r = request(:post) do |req|
        req.url "ra/apps/#{app_id}/platforms/ios/versions/#{version_id}"
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

    # Fetches the User Detail information from ITC
    # @return [UserDetail] the response
    def user_detail_data
      r = request(:get, '/WebObjects/iTunesConnect.woa/ra/user/detail')
      data = parse_response(r, 'data')
      Spaceship::Tunes::UserDetail.factory(data)
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

    def remove_testflight_build_from_review!(app_id: nil, train: nil, build_number: nil)
      r = request(:post) do |req|
        req.url "ra/apps/#{app_id}/trains/#{train}/builds/#{build_number}/reject"
        req.body = {}.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      handle_itc_response(r.body)
    end

    # rubocop:disable Metrics/AbcSize
    def submit_testflight_build_for_review!( # Required:
                                            app_id: nil,
                                            train: nil,
                                            build_number: nil,

                                            # Required Metadata:
                                            changelog: nil,
                                            description: nil,
                                            feedback_email: nil,
                                            marketing_url: nil,
                                            first_name: nil,
                                            last_name: nil,
                                            review_email: nil,
                                            phone_number: nil,

                                            # Optional Metadata:
                                            privacy_policy_url: nil,
                                            review_user_name: nil,
                                            review_password: nil,
                                            encryption: false)

      start_url = "ra/apps/#{app_id}/trains/#{train}/builds/#{build_number}/submit/start"
      r = request(:get) do |req|
        req.url start_url
        req.headers['Content-Type'] = 'application/json'
      end
      handle_itc_response(r.body)

      build_info = r.body['data']
      # Now fill in the values provided by the user

      # First the localised values:
      build_info['testInfo']['details'].each do |current|
        current['whatsNew']['value'] = changelog
        current['description']['value'] = description
        current['feedbackEmail']['value'] = feedback_email
        current['marketingUrl']['value'] = marketing_url
        current['privacyPolicyUrl']['value'] = privacy_policy_url
        current['pageLanguageValue'] = current['language'] # There is no valid reason why we need this, only iTC being iTC
      end
      build_info['testInfo']['reviewFirstName']['value'] = first_name
      build_info['testInfo']['reviewLastName']['value'] = last_name
      build_info['testInfo']['reviewPhone']['value'] = phone_number
      build_info['testInfo']['reviewEmail']['value'] = review_email
      build_info['testInfo']['reviewUserName']['value'] = review_user_name
      build_info['testInfo']['reviewPassword']['value'] = review_password

      r = request(:post) do |req| # same URL, but a POST request
        req.url start_url
        req.body = build_info.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      handle_itc_response(r.body)

      encryption_info = r.body['data']
      if encryption_info['exportComplianceRequired']
        # only sometimes this is required

        encryption_info['usesEncryption']['value'] = encryption

        r = request(:post) do |req|
          req.url "ra/apps/#{app_id}/trains/#{train}/builds/#{build_number}/submit/complete"
          req.body = encryption_info.to_json
          req.headers['Content-Type'] = 'application/json'
        end

        handle_itc_response(r.body)
      end
    end
    # rubocop:enable Metrics/AbcSize

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
              value: first_name
            },
            lastName: {
              value: last_name
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

    private

    # the contentProviderIr found in the UserDetail instance
    def content_provider_id
      user_detail_data.content_provider_id
    end

    # the ssoTokenForImage found in the AppVersionRef instance
    def sso_token_for_image
      ref_data.sso_token_for_image
    end

    # the ssoTokenForVideo found in the AppVersionRef instance
    def sso_token_for_video
      ref_data.sso_token_for_video
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
