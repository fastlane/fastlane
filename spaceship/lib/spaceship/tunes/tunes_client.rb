require "securerandom"
require_relative '../client'
require_relative '../du/du_client'
require_relative '../du/upload_file'
require_relative 'app_version_common'
require_relative 'app_version_ref'
require_relative 'availability'
require_relative 'errors'
require_relative 'iap_subscription_pricing_tier'
require_relative 'pricing_tier'
require_relative 'territory'
require_relative 'user_detail'
module Spaceship
  # rubocop:disable Metrics/ClassLength
  class TunesClient < Spaceship::Client
    # Legacy support
    ITunesConnectError = Tunes::Error
    ITunesConnectTemporaryError = Tunes::TemporaryError
    ITunesConnectPotentialServerError = Tunes::PotentialServerError

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
            'iphone58' => [2436, 1125],
            'iphone65' => [2688, 1242],
            'ipad' => [1024, 768],
            'ipad105' => [2224, 1668],
            'ipadPro' => [2732, 2048],
            'ipadPro11' => [2388, 1668],
            'ipadPro129' => [2732, 2048]
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
      "https://appstoreconnect.apple.com/WebObjects/iTunesConnect.woa/"
    end

    # Shows a team selection for the user in the terminal. This should not be
    # called on CI systems
    #
    # @param team_id (String) (optional): The ID of an App Store Connect team
    # @param team_name (String) (optional): The name of an App Store Connect team
    def select_team(team_id: nil, team_name: nil)
      t_id = (team_id || ENV['FASTLANE_ITC_TEAM_ID'] || '').strip
      t_name = (team_name || ENV['FASTLANE_ITC_TEAM_NAME'] || '').strip

      if t_name.length > 0 && t_id.length.zero? # we prefer IDs over names, they are unique
        puts("Looking for App Store Connect Team with name #{t_name}") if Spaceship::Globals.verbose?

        teams.each do |t|
          t_id = t['contentProvider']['contentProviderId'].to_s if t['contentProvider']['name'].casecmp(t_name).zero?
        end

        puts("Could not find team with name '#{t_name}', trying to fallback to default team") if t_id.length.zero?
      end

      t_id = teams.first['contentProvider']['contentProviderId'].to_s if teams.count == 1

      if t_id.length > 0
        puts("Looking for App Store Connect Team with ID #{t_id}") if Spaceship::Globals.verbose?

        # actually set the team id here
        self.team_id = t_id
        return self.team_id
      end

      # user didn't specify a team... #thisiswhywecanthavenicethings
      loop do
        puts("Multiple #{'App Store Connect teams'.yellow} found, please enter the number of the team you want to use: ")
        if ENV["FASTLANE_HIDE_TEAM_INFORMATION"].to_s.length == 0
          puts("Note: to automatically choose the team, provide either the App Store Connect Team ID, or the Team Name in your fastlane/Appfile:")
          puts("Alternatively you can pass the team name or team ID using the `FASTLANE_ITC_TEAM_ID` or `FASTLANE_ITC_TEAM_NAME` environment variable")
          first_team = teams.first["contentProvider"]
          puts("")
          puts("  itc_team_id \"#{first_team['contentProviderId']}\"")
          puts("")
          puts("or")
          puts("")
          puts("  itc_team_name \"#{first_team['name']}\"")
          puts("")
        end

        # We're not using highline here, as spaceship doesn't have a dependency to fastlane_core or highline
        teams.each_with_index do |team, i|
          puts("#{i + 1}) \"#{team['contentProvider']['name']}\" (#{team['contentProvider']['contentProviderId']})")
        end

        unless Spaceship::Client::UserInterface.interactive?
          puts("Multiple teams found on App Store Connect, Your Terminal is running in non-interactive mode! Cannot continue from here.")
          puts("Please check that you set FASTLANE_ITC_TEAM_ID or FASTLANE_ITC_TEAM_NAME to the right value.")
          raise "Multiple App Store Connect Teams found; unable to choose, terminal not interactive!"
        end

        selected = ($stdin.gets || '').strip.to_i - 1
        team_to_use = teams[selected] if selected >= 0

        if team_to_use
          self.team_id = team_to_use['contentProvider']['contentProviderId'].to_s # actually set the team id here
          return self.team_id
        end
      end
    end

    def send_login_request(user, password)
      clear_user_cached_data
      result = send_shared_login_request(user, password)

      store_cookie

      return result
    end

    # Sometimes we get errors or info nested in our data
    # This method allows you to pass in a set of keys to check for
    # along with the name of the sub_section of your original data
    # where we should check
    # Returns a mapping of keys to data array if we find anything, otherwise, empty map
    def fetch_errors_in_data(data_section: nil, sub_section_name: nil, keys: nil)
      if data_section && sub_section_name
        sub_section = data_section[sub_section_name]
      else
        sub_section = data_section
      end

      unless sub_section
        return {}
      end

      error_map = {}
      keys.each do |key|
        errors = sub_section.fetch(key, [])
        error_map[key] = errors if errors.count > 0
      end
      return error_map
    end

    # rubocop:disable Metrics/PerceivedComplexity
    # If the response is coming from a flaky api, set flaky_api_call to true so we retry a little.
    # Patience is a virtue.
    def handle_itc_response(raw, flaky_api_call: false)
      return unless raw
      return unless raw.kind_of?(Hash)

      data = raw['data'] || raw # sometimes it's with data, sometimes it isn't

      error_keys = ["sectionErrorKeys", "validationErrors", "serviceErrors"]
      info_keys = ["sectionInfoKeys", "sectionWarningKeys"]
      error_and_info_keys_to_check = error_keys + info_keys

      errors_in_data = fetch_errors_in_data(data_section: data, keys: error_and_info_keys_to_check)
      errors_in_version_info = fetch_errors_in_data(data_section: data, sub_section_name: "versionInfo", keys: error_and_info_keys_to_check)

      # If we have any errors or "info" we need to treat them as warnings or errors
      if errors_in_data.count == 0 && errors_in_version_info.count == 0
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

            next unless key == 'errorKeys' && value.kind_of?(Array) && value.count > 0
            # Prepend the error with the language so it's easier to understand for the user
            errors += value.collect do |current_error_message|
              current_language ? "[#{current_language}]: #{current_error_message}" : current_error_message
            end
          end
        elsif hash.kind_of?(Array)
          hash.each do |value|
            errors += handle_response_hash.call(value)
          end
          # else: We don't care about simple values
        end
        return errors
      end

      errors = handle_response_hash.call(data)

      # Search at data level, as well as "versionInfo" level for errors
      errors_in_data = fetch_errors_in_data(data_section: data, keys: error_keys)
      errors_in_version_info = fetch_errors_in_data(data_section: data, sub_section_name: "versionInfo", keys: error_keys)

      errors += errors_in_data.values if errors_in_data.values
      errors += errors_in_version_info.values if errors_in_version_info.values
      errors = errors.flat_map { |value| value }

      # Sometimes there is a different kind of error in the JSON response
      # e.g. {"warn"=>nil, "error"=>["operation_failed"], "info"=>nil}
      different_error = raw.fetch('messages', {}).fetch('error', nil)
      errors << different_error if different_error

      if errors.count > 0 # they are separated by `.` by default
        # Sample `error` content: [["Forbidden"]]
        if errors.count == 1 && errors.first == "You haven't made any changes."
          # This is a special error which we really don't care about
        elsif errors.count == 1 && errors.first.include?("try again later")
          raise ITunesConnectTemporaryError.new, errors.first
        elsif errors.count == 1 && errors.first.include?("Forbidden")
          raise_insufficient_permission_error!
        elsif flaky_api_call
          raise ITunesConnectPotentialServerError.new, errors.join(' ')
        else
          raise ITunesConnectError.new, errors.join(' ')
        end
      end

      # Search at data level, as well as "versionInfo" level for info and warnings
      info_in_data = fetch_errors_in_data(data_section: data, keys: info_keys)
      info_in_version_info = fetch_errors_in_data(data_section: data, sub_section_name: "versionInfo", keys: info_keys)

      info_in_data.each do |info_key, info_value|
        puts(info_value)
      end

      info_in_version_info.each do |info_key, info_value|
        puts(info_value)
      end

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

    def bundle_details(app_id)
      r = request(:get, "ra/appbundles/metadetail/#{app_id}")
      parse_response(r, 'data')
    end

    def update_app_details!(app_id, data)
      r = request(:post) do |req|
        req.url("ra/apps/#{app_id}/details")
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end

      handle_itc_response(r.body)
    end

    # Creates a new application on App Store Connect
    # @param name (String): The name of your app as it will appear on the App Store.
    #   This can't be longer than 255 characters.
    # @param primary_language (String): If localized app information isn't available in an
    #   App Store territory, the information from your primary language will be used instead.
    # @param version *DEPRECATED: Use `Spaceship::Tunes::Application.ensure_version!` method instead*
    #   (String): The version number is shown on the App Store and should match the one you used in Xcode.
    # @param sku (String): A unique ID for your app that is not visible on the App Store.
    # @param bundle_id (String): The bundle ID must match the one you used in Xcode. It
    #   can't be changed after you submit your first build.
    def create_application!(name: nil, primary_language: nil, version: nil, sku: nil, bundle_id: nil, bundle_id_suffix: nil, company_name: nil, platform: nil, platforms: nil, itunes_connect_users: nil)
      puts("The `version` parameter is deprecated. Use `Spaceship::Tunes::Application.ensure_version!` method instead") if version

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
      data['enabledPlatformsForCreation'] = { value: platforms || [platform] }

      unless itunes_connect_users.nil?
        data['iTunesConnectUsers']['grantedAllUsers'] = false
        data['iTunesConnectUsers']['grantedUsers'] = data['iTunesConnectUsers']['availableUsers'].select { |user| itunes_connect_users.include?(user['username']) }
      end

      # Now send back the modified hash
      r = request(:post) do |req|
        req.url('ra/apps/create/v2')
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end

      data = parse_response(r, 'data')
      handle_itc_response(data)
    end

    def create_version!(app_id, version_number, platform = 'ios')
      r = request(:post) do |req|
        req.url("ra/apps/#{app_id}/platforms/#{platform}/versions/create/")
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

    def get_available_bundle_ids(platform: nil)
      platform ||= "ios"
      r = request(:get, "ra/apps/create/v2/?platformString=#{platform}")
      data = parse_response(r, 'data')
      return data['bundleIds'].keys
    end

    def get_resolution_center(app_id, platform)
      r = request(:get, "ra/apps/#{app_id}/platforms/#{platform}/resolutionCenter?v=latest")
      parse_response(r, 'data')
    end

    def post_resolution_center(app_id, platform, thread_id, version_id, version_number, from, message_body)
      r = request(:post) do |req|
        req.url("ra/apps/#{app_id}/platforms/#{platform}/resolutionCenter")
        req.body = {
          appNotes: {
            threads: [{
              id: thread_id,
              versionId: version_id,
              version: version_number,
              messages: [{
                from: from,
                date: DateTime.now.strftime('%Q'),
                body: message_body,
                tokens: []
              }]
            }]
          }
        }.to_json
        req.headers['Content-Type'] = 'application/json'
      end

      data = parse_response(r, 'data')
      handle_itc_response(data)
    end

    def get_ratings(app_id, platform, version_id = '', storefront = '')
      # if storefront or version_id is empty api fails
      rating_url = "ra/apps/#{app_id}/platforms/#{platform}/reviews/summary"
      params = {}
      params['storefront'] = storefront unless storefront.empty?
      params['version_id'] = version_id unless version_id.empty?

      r = request(:get, rating_url, params)
      parse_response(r, 'data')
    end

    def get_reviews(app_id, platform, storefront, version_id, upto_date = nil)
      index = 0
      per_page = 100 # apple default
      all_reviews = []

      upto_date = Time.parse(upto_date) unless upto_date.nil?

      loop do
        rating_url = "ra/apps/#{app_id}/platforms/#{platform}/reviews?"
        rating_url << "sort=REVIEW_SORT_ORDER_MOST_RECENT"
        rating_url << "&index=#{index}"
        rating_url << "&storefront=#{storefront}" unless storefront.empty?
        rating_url << "&versionId=#{version_id}" unless version_id.empty?

        r = request(:get, rating_url)
        all_reviews.concat(parse_response(r, 'data')['reviews'])

        # The following lines throw errors when there are no reviews so exit out of the loop before them if the app has no reviews
        break if all_reviews.count == 0

        last_review_date = Time.at(all_reviews[-1]['value']['lastModified'] / 1000)

        if upto_date && last_review_date < upto_date
          all_reviews = all_reviews.select { |review| Time.at(review['value']['lastModified'] / 1000) > upto_date }
          break
        end

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
          req.url("ra/apps/#{app_id}/platforms/ios/versions/#{version_id}")
          req.body = data.to_json
          req.headers['Content-Type'] = 'application/json'
        end

        handle_itc_response(r.body, flaky_api_call: true)
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
        req.url("ra/users/itc/delete")
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
        req.url("ra/users/itc/create")
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      handle_itc_response(r.body)
    end

    def update_member_roles!(member, roles: [], apps: [])
      r = request(:get, "ra/users/itc/#{member.user_id}/roles")
      data = parse_response(r, 'data')

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
        req.url("ra/users/itc/#{member.user_id}/roles")
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      handle_itc_response(r.body)
    end

    #####################################################
    # @!group AppAnalytics
    #####################################################

    def time_series_analytics(app_ids, measures, start_time, end_time, frequency, view_by)
      data = {
        adamId: app_ids,
        dimensionFilters: [],
        endTime: end_time,
        frequency: frequency,
        group: group_for_view_by(view_by, measures),
        measures: measures,
        startTime: start_time
      }

      r = request(:post) do |req|
        req.url("https://analytics.itunes.apple.com/analytics/api/v1/data/time-series")
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
        req.headers['X-Requested-By'] = 'analytics.itunes.apple.com'
      end

      data = parse_response(r)
    end

    #####################################################
    # @!group Pricing
    #####################################################

    def update_price_tier!(app_id, price_tier)
      r = request(:get, "ra/apps/#{app_id}/pricing/intervals")
      data = parse_response(r, 'data')

      # preOrder isn't needed for for the request and has some
      # values that can cause a failure (invalid dates) so we are removing it
      data.delete('preOrder')

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
        req.url("ra/apps/#{app_id}/pricing/intervals")
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      handle_itc_response(r.body)
    end

    def transform_to_raw_pricing_intervals(app_id = nil, purchase_id = nil, pricing_intervals = 5, subscription_price_target = nil)
      intervals_array = []
      if pricing_intervals
        intervals_array = pricing_intervals.map do |interval|
          {
            "value" =>  {
              "tierStem" =>  interval[:tier],
              "priceTierEffectiveDate" =>  interval[:begin_date],
              "priceTierEndDate" =>  interval[:end_date],
              "country" =>  interval[:country] || "WW",
              "grandfathered" =>  interval[:grandfathered]
            }
          }
        end
      end

      if subscription_price_target
        pricing_calculator = iap_subscription_pricing_target(app_id: app_id, purchase_id: purchase_id, currency: subscription_price_target[:currency], tier: subscription_price_target[:tier])
        intervals_array = pricing_calculator.map do |language_code, value|
          existing_interval =
            if pricing_intervals
              pricing_intervals.find { |interval| interval[:country] == language_code }
            end
          grandfathered =
            if existing_interval
              existing_interval[:grandfathered].clone
            else
              { "value" => "FUTURE_NONE" }
            end

          {
            "value" => {
              "tierStem" => value["tierStem"],
              "priceTierEffectiveDate" => value["priceTierEffectiveDate"],
              "priceTierEndDate" => value["priceTierEndDate"],
              "country" => language_code,
              "grandfathered" => grandfathered
            }
          }
        end
      end

      intervals_array
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

      # InitializespreOrder (if needed)
      data["preOrder"] ||= {}

      # Sets app_available_date to nil if cleared_for_preorder if false
      # This is need for apps that have never set either of these before
      # API will error out if cleared_for_preorder is false and app_available_date has a date
      cleared_for_preorder = availability.cleared_for_preorder
      app_available_date = cleared_for_preorder ? availability.app_available_date : nil
      data["b2bAppEnabled"] = availability.b2b_app_enabled
      data["educationalDiscount"] = availability.educational_discount
      data["preOrder"]["clearedForPreOrder"] = { "value" => cleared_for_preorder, "isEditable" => true, "isRequired" => true, "errorKeys" => nil }
      data["preOrder"]["appAvailableDate"] = { "value" => app_available_date, "isEditable" => true, "isRequired" => true, "errorKeys" => nil }
      data["b2bUsers"] = availability.b2b_app_enabled ? availability.b2b_users.map { |user| { "value" => { "add" => user.add, "delete" => user.delete, "dsUsername" => user.ds_username } } } : []
      data["b2bOrganizations"] = availability.b2b_app_enabled ? availability.b2b_organizations.map { |org| { "value" => { "type" => org.type, "depCustomerId" => org.dep_customer_id, "organizationId" => org.dep_organization_id, "name" => org.name } } } : []
      # send the changes back to Apple
      r = request(:post) do |req|
        req.url("ra/apps/#{app_id}/pricing/intervals")
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
      r = request(:get, "ra/ref")
      parse_response(r, 'data')['detailLocales']
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

    # Uploads an In-App-Purchase Promotional image
    # @param upload_image (UploadFile): The icon to upload
    # @return [JSON] the image data, ready to be added to an In-App-Purchase
    def upload_purchase_merch_screenshot(app_id, upload_image)
      data = du_client.upload_purchase_merch_screenshot(app_id, upload_image, content_provider_id, sso_token_for_image)
      {
        "images" => [
          {
            "id" => nil,
            "image" => {
              "value" => {
                "assetToken" => data["token"],
                "originalFileName" => upload_image.file_name,
                "height" => data["height"],
                "width" => data["width"],
                "checksum" => data["md5"]
              },
              "isEditable" => true,
              "isREquired" => false,
              "errorKeys" => nil
            },
            "status" => "proposed"
          }
        ],
        "showByDefault" => true,
        "isActive" => false
      }
    end

    # Uploads an In-App-Purchase Review screenshot
    # @param app_id (AppId): The id of the app
    # @param upload_image (UploadFile): The icon to upload
    # @return [JSON] the screenshot data, ready to be added to an In-App-Purchase
    def upload_purchase_review_screenshot(app_id, upload_image)
      data = du_client.upload_purchase_review_screenshot(app_id, upload_image, content_provider_id, sso_token_for_image)
      {
          "value" => {
              "assetToken" => data["token"],
              "sortOrder" => 0,
              "type" => du_client.get_picture_type(upload_image),
              "originalFileName" => upload_image.file_name,
              "size" => data["length"],
              "height" => data["height"],
              "width" => data["width"],
              "checksum" => data["md5"]
          }
      }
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
    # @param device (string): The target device
    # @return [JSON] the response
    def upload_trailer_preview(app_version, upload_trailer_preview, device)
      raise "app_version is required" unless app_version
      raise "upload_trailer_preview is required" unless upload_trailer_preview
      raise "device is required" unless device

      du_client.upload_trailer_preview(app_version, upload_trailer_preview, content_provider_id, sso_token_for_image, device)
    end

    #####################################################
    # @!review attachment file
    #####################################################
    # Uploads a attachment file
    # @param app_version (AppVersion): The version of your app(must be edit version)
    # @param upload_attachment_file (file): File to upload
    # @return [JSON] the response
    def upload_app_review_attachment(app_version, upload_attachment_file)
      raise "app_version is required" unless app_version
      raise "app_version must be live version" if app_version.is_live?
      raise "upload_attachment_file is required" unless upload_attachment_file

      du_client.upload_app_review_attachment(app_version, upload_attachment_file, content_provider_id, sso_token_for_image)
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
      @_cached_user_detail_data ||= Spaceship::Tunes::UserDetail.factory(user_details_data, self)
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
          logger.warn("Received temporary server error from App Store Connect. Retrying the request...")
          sleep(3) unless Object.const_defined?("SpecHelper")
          retry
        end
      end

      raise Spaceship::Client::UnexpectedResponse, "Temporary App Store Connect error: #{ex}"
    end
    # rubocop:enable Metrics/BlockNesting

    def update_build_trains!(app_id, testing_type, data)
      raise "app_id is required" unless app_id

      # The request fails if this key is present in the data
      data.delete("dailySubmissionCountByPlatform")

      r = request(:post) do |req|
        req.url("ra/apps/#{app_id}/testingTypes/#{testing_type}/trains/")
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end

      handle_itc_response(r.body)
    end

    def remove_testflight_build_from_review!(app_id: nil, train: nil, build_number: nil, platform: 'ios')
      r = request(:post) do |req|
        req.url("ra/apps/#{app_id}/platforms/#{platform}/trains/#{train}/builds/#{build_number}/reject")
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
        req.url(url)
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

      # First the localized values:
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
        req.url("ra/apps/#{app_id}/platforms/#{platform}/trains/#{train}/builds/#{build_number}/review/submit")

        req.body = review_info.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      handle_itc_response(r.body)
    end
    # rubocop:enable Metrics/ParameterLists

    def get_build_info_for_review(app_id: nil, train: nil, build_number: nil, platform: 'ios')
      url = "ra/apps/#{app_id}/platforms/#{platform}/trains/#{train}/builds/#{build_number}/testInformation"
      r = request(:get) do |req|
        req.url(url)
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
        req.url("ra/apps/#{app_id}/versions/#{version}/submit/summary")
        req.headers['Content-Type'] = 'application/json'
      end

      handle_itc_response(r.body)
      parse_response(r, 'data')
    end

    def send_app_submission(app_id, version, data)
      raise "app_id is required" unless app_id

      # ra/apps/1039164429/version/submit/complete
      r = request(:post) do |req|
        req.url("ra/apps/#{app_id}/versions/#{version}/submit/complete")
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end

      handle_itc_response(r.body)

      # App Store Connect still returns a success status code even the submission
      # was failed because of Ad ID Info / Export Compliance. This checks for any section error
      # keys in returned adIdInfo / exportCompliance and prints them out.
      ad_id_error_keys = r.body.fetch('data').fetch('adIdInfo').fetch('sectionErrorKeys')
      export_error_keys = r.body.fetch('data').fetch('exportCompliance').fetch('sectionErrorKeys')
      if ad_id_error_keys.any?
        raise "Something wrong with your Ad ID information: #{ad_id_error_keys}."
      elsif export_error_keys.any?
        raise "Something wrong with your Export Compliance: #{export_error_keys}"
      elsif r.body.fetch('messages').fetch('info').last == "Successful POST"
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
        req.url("ra/apps/#{app_id}/versions/#{version}/releaseToStore")
        req.headers['Content-Type'] = 'application/json'
        req.body = app_id.to_s
      end

      handle_itc_response(r.body)
      parse_response(r, 'data')
    end

    #####################################################
    # @!group release to all users
    #####################################################

    def release_to_all_users!(app_id, version)
      raise "app_id is required" unless app_id
      raise "version is required" unless version

      r = request(:post) do |req|
        req.url("ra/apps/#{app_id}/versions/#{version}/phasedRelease/state/COMPLETE")
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

    # Submit the In-App-Purchase for review
    def submit_iap!(app_id: nil, purchase_id: nil)
      r = request(:post, "ra/apps/#{app_id}/iaps/#{purchase_id}/submission")
      handle_itc_response(r)
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
          req.url("ra/apps/#{app_id}/iaps/family/#{family_id}/")
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
          req.url("ra/apps/#{app_id}/iaps/#{purchase_id}")
          req.body = data.to_json
          req.headers['Content-Type'] = 'application/json'
        end
        handle_itc_response(r.body)
      end
    end

    def update_recurring_iap_pricing!(app_id: nil, purchase_id: nil, pricing_intervals: nil)
      with_tunes_retry do
        r = request(:post) do |req|
          pricing_data = {}
          req.url("ra/apps/#{app_id}/iaps/#{purchase_id}/pricing/subscriptions")
          pricing_data["subscriptions"] = pricing_intervals
          req.body = pricing_data.to_json
          req.headers['Content-Type'] = 'application/json'
        end
        handle_itc_response(r.body)
      end
    end

    def load_recurring_iap_pricing(app_id: nil, purchase_id: nil)
      r = request(:get, "ra/apps/#{app_id}/iaps/#{purchase_id}/pricing")
      parse_response(r, 'data')
    end

    def create_iap_family(app_id: nil, name: nil, product_id: nil, reference_name: nil, versions: [])
      r = request(:get, "ra/apps/#{app_id}/iaps/family/template")
      data = parse_response(r, 'data')

      data['activeAddOns'][0]['productId'] = { value: product_id }
      data['activeAddOns'][0]['referenceName'] = { value: reference_name }
      data['name'] = { value: name }
      data["details"]["value"] = versions

      r = request(:post) do |req|
        req.url("ra/apps/#{app_id}/iaps/family/")
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
    def create_iap!(app_id: nil, type: nil, versions: nil, reference_name: nil, product_id: nil, cleared_for_sale: true, merch_screenshot: nil, review_notes: nil, review_screenshot: nil, pricing_intervals: nil, family_id: nil, subscription_duration: nil, subscription_free_trial: nil)
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

      if merch_screenshot
        # Upload App Store Promotional image (Optional)
        upload_file = UploadFile.from_path(merch_screenshot)
        merch_data = upload_purchase_merch_screenshot(app_id, upload_file)
        data["versions"][0]["merch"] = merch_data
      end

      if review_screenshot
        # Upload Screenshot:
        upload_file = UploadFile.from_path(review_screenshot)
        screenshot_data = upload_purchase_review_screenshot(app_id, upload_file)
        data["versions"][0]["reviewScreenshot"] = screenshot_data
      end

      # Now send back the modified hash
      r = request(:post) do |req|
        req.url("ra/apps/#{app_id}/iaps")
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      handle_itc_response(r.body)
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
        req.url(url)
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
      response_object = parse_response(r, 'data')
      errors = response_object['sectionErrorKeys']
      raise ITunesConnectError, errors.join(' ') unless errors.empty?
      response_object['user']
    end

    def delete_sandbox_testers!(tester_class, emails)
      url = tester_class.url[:delete]
      request(:post) do |req|
        req.url(url)
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
      data = [{
        numberOfCodes: quantity,
        agreedToContract: true,
        versionId: version_id
      }]
      url = "ra/apps/#{app_id}/promocodes/versions"
      r = request(:post) do |req|
        req.url(url)
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
        req.url("ra/apps/#{app_id}/versions/#{version}/reject")
        req.headers['Content-Type'] = 'application/json'
        req.body = app_id.to_s
      end

      handle_itc_response(r.body)
      parse_response(r, 'data')
    end

    private

    def with_tunes_retry(tries = 5, potential_server_error_tries = 3, &_block)
      return yield
    rescue Spaceship::TunesClient::ITunesConnectTemporaryError => ex
      seconds_to_sleep = 60
      unless (tries -= 1).zero?
        msg = "App Store Connect temporary error received: '#{ex.message}'. Retrying after #{seconds_to_sleep} seconds (remaining: #{tries})..."
        puts(msg)
        logger.warn(msg)
        sleep(seconds_to_sleep) unless Object.const_defined?("SpecHelper")
        retry
      end
      raise ex # re-raise the exception
    rescue Spaceship::TunesClient::ITunesConnectPotentialServerError => ex
      seconds_to_sleep = 10
      unless (potential_server_error_tries -= 1).zero?
        msg = "Potential server error received: '#{ex.message}'. Retrying after 10 seconds (remaining: #{potential_server_error_tries})..."
        puts(msg)
        logger.warn(msg)
        sleep(seconds_to_sleep) unless Object.const_defined?("SpecHelper")
        retry
      end
      raise ex
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

    # generates group hash used in the analytics time_series API.
    # Using rank=DESCENDING and limit=3 as this is what the App Store Connect analytics dashboard uses.
    def group_for_view_by(view_by, measures)
      if view_by.nil? || measures.nil?
        return nil
      else
        return {
          metric: measures.first,
          dimension: view_by,
          rank: "DESCENDING",
          limit: 3
        }
      end
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
        req.url(url)
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end

      data = parse_response(r, 'data')
      handle_itc_response(data)
    end
  end
  # rubocop:enable Metrics/ClassLength
end
