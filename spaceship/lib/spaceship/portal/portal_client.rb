module Spaceship
  class PortalConstants < Spaceship::Client
    APP_ID_URL = {
        Spaceship::Portal::App::IOS => 'account/ios/identifiers/listAppIds.action',
        Spaceship::Portal::App::WEB => 'account/ios/identifiers/listWebsitePushIds.action',
        Spaceship::Portal::App::TVOS => 'account/ios/identifiers/listAppIds.action',
        Spaceship::Portal::App::MAC => 'account/mac/identifiers/listAppIds.action',
        Spaceship::Portal::App::PASS => 'account/ios/identifiers/listPassTypeIds.action',
        Spaceship::Portal::App::ICLOUD => 'account/cloudContainer/listCloudContainers.action',
        Spaceship::Portal::App::MERCHANT => 'account/ios/identifiers/listOMCs.action'
    }.freeze

    EXPECTED_KEY_APP_ID_URL = {
        Spaceship::Portal::App::IOS => 'appIds',
        Spaceship::Portal::App::WEB => 'websitePushIdList',
        Spaceship::Portal::App::TVOS => 'appIds',
        Spaceship::Portal::App::MAC => 'appIds',
        Spaceship::Portal::App::PASS => 'passTypeIdList',
        Spaceship::Portal::App::ICLOUD => 'cloudContainerList',
        Spaceship::Portal::App::MERCHANT => 'identifierList'
    }.freeze

    CREATE_APP_ID_URL = {
        Spaceship::Portal::App::IOS => 'account/ios/identifiers/addAppId.action',
        Spaceship::Portal::App::WEB => 'account/ios/identifiers/addWebsitePushId.action',
        Spaceship::Portal::App::TVOS => 'account/ios/identifiers/addAppId.action',
        Spaceship::Portal::App::MAC => 'account/mac/identifiers/addAppId.action',
        Spaceship::Portal::App::PASS => 'account/ios/identifiers/addPassTypeId.action',
        Spaceship::Portal::App::ICLOUD => 'account/cloudContainer/addCloudContainer.action',
        Spaceship::Portal::App::MERCHANT => 'account/ios/identifiers/addOMC.action'
    }.freeze

    DELETE_APP_ID_URL = {
        Spaceship::Portal::App::IOS => 'account/ios/identifiers/deleteAppId.action',
        Spaceship::Portal::App::WEB => 'account/ios/identifiers/deleteWebsitePushId.action',
        Spaceship::Portal::App::TVOS => 'account/ios/identifiers/deleteAppId.action',
        Spaceship::Portal::App::MAC => 'account/mac/identifiers/deleteAppId.action',
        Spaceship::Portal::App::PASS => 'account/ios/identifiers/deletePassTypeId.action',
        Spaceship::Portal::App::ICLOUD => '', # You can not delete iCloud Containers
        Spaceship::Portal::App::MERCHANT => 'account/ios/identifiers/deleteOMC.action'
    }.freeze
  end

  # rubocop:disable Metrics/ClassLength
  class PortalClient < Spaceship::Client
    #####################################################
    # @!group Init and Login
    #####################################################

    def self.hostname
      "https://developer.apple.com/services-account/#{PROTOCOL_VERSION}/"
    end

    # Fetches the latest API Key from the Apple Dev Portal
    def api_key
      cache_path = File.expand_path("~/Library/Caches/spaceship_api_key.txt")
      begin
        cached = File.read(cache_path)
      rescue Errno::ENOENT
      end
      return cached if cached

      landing_url = "https://developer.apple.com/account/"
      logger.info("GET: " + landing_url)
      headers = @client.get(landing_url).headers
      results = headers['location'].match(/.*appIdKey=(\h+)/)
      if (results || []).length > 1
        api_key = results[1]
        FileUtils.mkdir_p(File.dirname(cache_path))
        File.write(cache_path, api_key) if api_key.length == 64
        return api_key
      else
        raise "Could not find latest API Key from the Dev Portal - the server might be slow right now"
      end
    end

    def send_login_request(user, password)
      response = send_shared_login_request(user, password)
      return response if self.cookie.include?("myacinfo")

      # When the user has 2 step enabled, we might have to call this method again
      # This only occurs when the user doesn't have a team on iTunes Connect
      # For 2 step verification we use the iTunes Connect back-end
      # which is enough to get the DES... cookie, however we don't get a valid
      # myacinfo cookie at that point. That means, after getting the DES... cookie
      # we have to send the login request again. This will then get us a valid myacinfo
      # cookie, additionally to the DES... cookie
      return send_shared_login_request(user, password)
    end

    # @return (Array) A list of all available teams
    def teams
      return @teams if @teams
      req = request(:post, "https://developerservices2.apple.com/services/QH65B2/listTeams.action")
      @teams = parse_response(req, 'teams').sort_by do |team|
        [
          team['name'],
          team['teamId']
        ]
      end
    end

    # @return (String) The currently selected Team ID
    def team_id
      return @current_team_id if @current_team_id

      if teams.count > 1
        puts "The current user is in #{teams.count} teams. Pass a team ID or call `select_team` to choose a team. Using the first one for now."
      end
      @current_team_id ||= teams[0]['teamId']
    end

    # Shows a team selection for the user in the terminal. This should not be
    # called on CI systems
    def select_team
      @current_team_id = self.UI.select_team
    end

    # Set a new team ID which will be used from now on
    def team_id=(team_id)
      @current_team_id = team_id
    end

    # @return (Hash) Fetches all information of the currently used team
    def team_information
      teams.find do |t|
        t['teamId'] == team_id
      end
    end

    # Is the current session from an Enterprise In House account?
    def in_house?
      return @in_house unless @in_house.nil?
      @in_house = (team_information['type'] == 'In-House')
    end

    def platform_slug(platform)
      if platform == Spaceship::Portal::App::MAC
        Spaceship::Portal::App::MAC
      else
        Spaceship::Portal::App::IOS
      end
    end
    private :platform_slug

    #####################################################
    # @!group Apps
    #####################################################

    # <b>DEPRECATED:</b> Use <tt>apps_by_platform</tt> instead.
    def apps(mac: false)
      puts '`apps` is deprecated. Please use `apps_by_platform` instead.'.red
      apps_by_platform(platform: mac ? Spaceship::Portal::App::MAC : Spaceship::Portal::App::IOS)
    end

    def apps_by_platform(platform: nil)
      platforms = [platform]
      platforms = Spaceship::Portal::App::PLATFORMS if platform.nil?

      results = []

      platforms.each do |the_platform|
        output = paging do |page_number|
          r = request(:post, Spaceship::PortalConstants::APP_ID_URL[the_platform], {
              teamId: team_id,
              pageNumber: page_number,
              pageSize: page_size,
              sort: 'name=asc'
          })
          parse_response(r, Spaceship::PortalConstants::EXPECTED_KEY_APP_ID_URL[the_platform])
        end

        # We add the platform here for some of the app platform types because there response data does not include it.
        output.each {|app| app['appIdPlatform'] = the_platform } if Spaceship::Portal::App::ADD_PLATFORM.include? the_platform
        results += output
      end

      results
    end

    def details_for_app(app)
      raise "The developer portal does not allow details requests for platform: #{app.platform}" unless can_request_details_for(app.platform)

      r = request(:post, "account/#{platform_slug(app.platform)}/identifiers/getAppIdDetail.action", {
        teamId: team_id,
        appIdId: app.app_id
      })
      parse_response(r, 'appId')
    end

    def can_request_details_for(platform)
      ![
        Spaceship::Portal::App::MERCHANT,
        Spaceship::Portal::App::ICLOUD,
        Spaceship::Portal::App::PASS,
        Spaceship::Portal::App::WEB
      ].include?(platform)
    end

    def update_service_for_app(app, service)
      request(:post, service.service_uri, {
        teamId: team_id,
        displayId: app.app_id,
        featureType: service.service_id,
        featureValue: service.value
      })

      details_for_app(app)
    end

    def associate_groups_with_app(app, groups)
      request(:post, 'account/ios/identifiers/assignApplicationGroupToAppId.action', {
        teamId: team_id,
        appIdId: app.app_id,
        displayId: app.app_id,
        applicationGroups: groups.map(&:app_group_id)
      })

      details_for_app(app)
    end

    # <b>DEPRECATED:</b> Use <tt>create_app_by_platform!</tt> instead.
    def create_app!(type, name, bundle_id, mac: false)
      puts '`create_app!` is deprecated. Please use `create_app_by_platform!` instead.'.red
      create_app_by_platform!(type, name, bundle_id, platform: mac ? Spaceship::Portal::App::MAC : Spaceship::Portal::App::IOS)
    end

    def create_app_by_platform!(type, name, bundle_id, platform: Spaceship::Portal::App::IOS)
      ident_params = case type.to_sym
                     when :explicit
                       {
                           type: 'explicit',
                           explicitIdentifier: bundle_id,
                           appIdentifierString: bundle_id,
                           push: 'on',
                           inAppPurchase: 'on',
                           gameCenter: 'on'
                       }
                     when :wildcard
                       {
                           type: 'wildcard',
                           wildcardIdentifier: bundle_id,
                           appIdentifierString: bundle_id
                       }
                     end

      params = {
          appIdName: name,
          teamId: team_id
      }

      params.merge!(ident_params)

      ensure_csrf

      r = request(:post, Spaceship::PortalConstants::CREATE_APP_ID_URL[platform], params)
      parse_response(r, 'appId')
    end

    # <b>DEPRECATED:</b> Use <tt>delete_app_by_platform!</tt> instead.
    def delete_app!(app_id, mac: false)
      puts '`delete_app!` is deprecated. Please use `delete_app_by_platform!` instead.'.red
      delete_app_by_platform!(app_id, platform: mac ? Spaceship::Portal::App::MAC : Spaceship::Portal::App::IOS)
    end

    def delete_app_by_platform!(app_id, platform: Spaceship::Portal::App::IOS)
      raise 'The developer portal does not allow deleting of iCloud Container App Ids' if platform == Spaceship::Portal::App::ICLOUD

      r = request(:post, Spaceship::PortalConstants::DELETE_APP_ID_URL[platform], {
          teamId: team_id,
          appIdId: app_id
      })
      parse_response(r)
    end
    #####################################################
    # @!group App Groups
    #####################################################

    def app_groups
      paging do |page_number|
        r = request(:post, 'account/ios/identifiers/listApplicationGroups.action', {
          teamId: team_id,
          pageNumber: page_number,
          pageSize: page_size,
          sort: 'name=asc'
        })
        parse_response(r, 'applicationGroupList')
      end
    end

    def create_app_group!(name, group_id)
      r = request(:post, 'account/ios/identifiers/addApplicationGroup.action', {
        name: name,
        identifier: group_id,
        teamId: team_id
      })
      parse_response(r, 'applicationGroup')
    end

    def delete_app_group!(app_group_id)
      r = request(:post, 'account/ios/identifiers/deleteApplicationGroup.action', {
        teamId: team_id,
        applicationGroup: app_group_id
      })
      parse_response(r)
    end

    #####################################################
    # @!group Devices
    #####################################################

    # <b>DEPRECATED:</b> Use <tt>devices_by_platform</tt> instead.
    def devices(mac: false)
      puts '`devices` is deprecated. Please use `devices_by_platform` instead.'.red
      devices_by_platform(platform: mac ? Spaceship::Portal::App::MAC : Spaceship::Portal::App::IOS)
    end

    def devices_by_platform(platform: Spaceship::Portal::App::IOS)
      paging do |page_number|
        r = request(:post, "account/#{platform_slug(platform)}/device/listDevices.action", {
          teamId: team_id,
          pageNumber: page_number,
          pageSize: page_size,
          sort: 'name=asc'
        })
        parse_response(r, 'devices')
      end
    end

    def devices_by_class(device_class)
      paging do |page_number|
        r = request(:post, 'account/ios/device/listDevices.action', {
          teamId: team_id,
          pageNumber: page_number,
          pageSize: page_size,
          sort: 'name=asc',
          deviceClasses: device_class
        })
        parse_response(r, 'devices')
      end
    end

    # <b>DEPRECATED:</b> Use <tt>create_device_by_platform!</tt> instead.
    def create_device!(device_name, device_id, mac: false)
      puts '`create_device!` is deprecated. Please use `create_device_by_platform!` instead.'.red
      create_device_by_platform!(device_name, device_id, platform: mac ? Spaceship::Portal::App::MAC : Spaceship::Portal::App::IOS)
    end

    def create_device_by_platform!(device_name, device_id, platform: Spaceship::Portal::App::IOS)
      req = request(:post) do |r|
        r.url "https://developerservices2.apple.com/services/#{PROTOCOL_VERSION}/#{platform_slug(platform)}/addDevice.action"
        r.params = {
            teamId: team_id,
            deviceNumber: device_id,
            name: device_name
        }
      end

      parse_response(req, 'device')
    end

    #####################################################
    # @!group Certificates
    #####################################################

    # <b>DEPRECATED:</b> Use <tt>certificates_by_platform</tt> instead.
    def certificates(types, mac: false)
      puts '`certificates` is deprecated. Please use `certificates_by_platform` instead.'.red
      certificates_by_platform(types, platform: mac ? Spaceship::Portal::App::MAC : Spaceship::Portal::App::IOS)
    end

    def certificates_by_platform(types, platform: Spaceship::Portal::App::IOS)
      paging do |page_number|
        r = request(:post, "account/#{platform_slug(platform)}/certificate/listCertRequests.action", {
          teamId: team_id,
          types: types.join(','),
          pageNumber: page_number,
          pageSize: page_size,
          sort: 'certRequestStatusCode=asc'
        })
        parse_response(r, 'certRequests')
      end
    end

    def create_certificate!(type, csr, app_id)
      ensure_csrf

      params = {
        teamId: team_id,
        type: type,
        csrContent: csr
      }

      if Certificate::CERTIFICATE_TYPE_IDS[type] == Spaceship::Portal::Certificate::WebsitePush
        params['websitePushId'] = app_id
      elsif Certificate::CERTIFICATE_TYPE_IDS[type] == Spaceship::Portal::Certificate::Passbook
        params['passTypeId'] = app_id
      elsif Certificate::CERTIFICATE_TYPE_IDS[type] == Spaceship::Portal::Certificate::ApplePay
        params['omcId'] = app_id
      else
        params['appIdId'] = app_id # Optional
      end

      params['specialIdentifierDisplayId'] = app_id

      r = request(:post, 'account/ios/certificate/submitCertificateRequest.action', params)
      parse_response(r, 'certRequest')
    end

    # <b>DEPRECATED:</b> Use <tt>download_certificate_by_platform</tt> instead.
    def download_certificate(certificate_id, type, mac: false)
      puts '`download_certificate` is deprecated. Please use `download_certificate_by_platform` instead.'.red
      download_certificate_by_platform(certificate_id, type, platform: mac ? Spaceship::Portal::App::MAC : Spaceship::Portal::App::IOS)
    end

    def download_certificate_by_platform(certificate_id, type, platform: Spaceship::Portal::App::IOS)
      { type: type, certificate_id: certificate_id }.each { |k, v| raise "#{k} must not be nil" if v.nil? }

      r = request(:get, "account/#{platform_slug(platform)}/certificate/downloadCertificateContent.action", {
        teamId: team_id,
        certificateId: certificate_id,
        type: type
      })
      a = parse_response(r)
      if r.success? && a.include?("Apple Inc")
        return a
      else
        raise UnexpectedResponse.new, "Couldn't download certificate, got this instead: #{a}"
      end
    end

    # <b>DEPRECATED:</b> Use <tt>revoke_certificate_by_platform!</tt> instead.
    def revoke_certificate!(certificate_id, type, mac: false)
      puts '`revoke_certificate!` is deprecated. Please use `revoke_certificate_by_platform!` instead.'.red
      revoke_certificate_by_platform!(certificate_id, type, platform: mac ? Spaceship::Portal::App::MAC : Spaceship::Portal::App::IOS)
    end

    def revoke_certificate_by_platform!(certificate_id, type, platform: Spaceship::Portal::App::IOS)
      r = request(:post, "account/#{platform_slug(platform)}/certificate/revokeCertificate.action", {
          teamId: team_id,
          certificateId: certificate_id,
          type: type
      })
      parse_response(r, 'certRequests')
    end

    #####################################################
    # @!group Provisioning Profiles
    #####################################################

    # <b>DEPRECATED:</b> Use <tt>provisioning_profiles_by_platform</tt> instead.
    def provisioning_profiles(mac: false)
      puts '`provisioning_profiles` is deprecated. Please use `provisioning_profiles_by_platform` instead.'.red
      provisioning_profiles_by_platform(platform: mac ? Spaceship::Portal::App::MAC : Spaceship::Portal::App::IOS)
    end

    def provisioning_profiles_by_platform(platform: Spaceship::Portal::App::IOS)
      req = request(:post) do |r|
        r.url "https://developerservices2.apple.com/services/#{PROTOCOL_VERSION}/#{platform_slug(platform)}/listProvisioningProfiles.action"
        r.params = {
            teamId: team_id,
            includeInactiveProfiles: true,
            onlyCountLists: true
        }
      end

      parse_response(req, 'provisioningProfiles')
    end

    # <b>DEPRECATED:</b> Use <tt>create_provisioning_profile_by_platform!</tt> instead.
    def create_provisioning_profile!(name, distribution_method, app_id, certificate_ids, device_ids, mac: false, sub_platform: nil)
      puts '`create_provisioning_profile!` is deprecated. Please use `create_provisioning_profile_by_platform!` instead.'.red
      create_provisioning_profile_by_platform!(name, distribution_method, app_id, certificate_ids, device_ids, platform: mac ? Spaceship::Portal::App::MAC : Spaceship::Portal::App::IOS)
    end

    def create_provisioning_profile_by_platform!(name, distribution_method, app_id, certificate_ids, device_ids, platform: Spaceship::Portal::App::IOS, sub_platform: nil)
      ensure_csrf

      params = {
          teamId: team_id,
          provisioningProfileName: name,
          appIdId: app_id,
          distributionType: distribution_method,
          certificateIds: certificate_ids,
          deviceIds: device_ids
      }

      params[:subPlatform] = sub_platform unless sub_platform.nil?

      r = request(:post, "account/#{platform_slug(platform)}/profile/createProvisioningProfile.action", params)
      parse_response(r, 'provisioningProfile')
    end

    # <b>DEPRECATED:</b> Use <tt>create_provisioning_profile_by_platform!</tt> instead.
    def download_provisioning_profile(profile_id, mac: false)
      puts '`download_provisioning_profile` is deprecated. Please use `download_provisioning_profile_by_platform` instead.'.red
      download_provisioning_profile_by_platform(profile_id, platform: mac ? Spaceship::Portal::App::MAC : Spaceship::Portal::App::IOS)
    end

    def download_provisioning_profile_by_platform(profile_id, platform: Spaceship::Portal::App::IOS)
      r = request(:get, "account/#{platform_slug(platform)}/profile/downloadProfileContent", {
        teamId: team_id,
        provisioningProfileId: profile_id
      })
      a = parse_response(r)
      if r.success? && a.include?("DOCTYPE plist PUBLIC")
        return a
      else
        raise UnexpectedResponse.new, "Couldn't download provisioning profile, got this instead: #{a}"
      end
    end

    # <b>DEPRECATED:</b> Use <tt>delete_provisioning_profile_by_platform!</tt> instead.
    def delete_provisioning_profile!(profile_id, mac: false)
      puts '`delete_provisioning_profile!` is deprecated. Please use `delete_provisioning_profile_by_platform!` instead.'.red
      delete_provisioning_profile_by_platform!(profile_id, platform: mac ? Spaceship::Portal::App::MAC : Spaceship::Portal::App::IOS)
    end

    def delete_provisioning_profile_by_platform!(profile_id, platform: Spaceship::Portal::App::IOS)
      ensure_csrf

      r = request(:post, "account/#{platform_slug(platform)}/profile/deleteProvisioningProfile.action", {
        teamId: team_id,
        provisioningProfileId: profile_id
      })
      parse_response(r)
    end

    # <b>DEPRECATED:</b> Use <tt>repair_provisioning_profile_by_platform!</tt> instead.
    def repair_provisioning_profile!(profile_id, name, distribution_method, app_id, certificate_ids, device_ids, mac: false)
      puts '`repair_provisioning_profile!` is deprecated. Please use `repair_provisioning_profile_by_platform!` instead.'.red
      repair_provisioning_profile_by_platform!(profile_id, name, distribution_method, app_id, certificate_ids, device_ids, platform: mac ? Spaceship::Portal::App::MAC : Spaceship::Portal::App::IOS)
    end

    def repair_provisioning_profile_by_platform!(profile_id, name, distribution_method, app_id, certificate_ids, device_ids, platform: Spaceship::Portal::App::IOS)
      r = request(:post, "account/#{platform_slug(platform)}/profile/regenProvisioningProfile.action", {
        teamId: team_id,
        provisioningProfileId: profile_id,
        provisioningProfileName: name,
        appIdId: app_id,
        distributionType: distribution_method,
        certificateIds: certificate_ids.join(','),
        deviceIds: device_ids
      })

      parse_response(r, 'provisioningProfile')
    end

    private

    def ensure_csrf
      if csrf_tokens.count == 0
        # If we directly create a new resource (e.g. app) without querying anything before
        # we don't have a valid csrf token, that's why we have to do at least one request
        apps
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
