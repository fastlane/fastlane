module Spaceship
  # rubocop:disable Metrics/ClassLength
  class PortalClient < Spaceship::Client
    #####################################################
    # @!group Init and Login
    #####################################################

    def self.hostname
      "https://developer.apple.com/services-account/#{PROTOCOL_VERSION}/"
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

      if teams.count == 0
        raise "User '#{user}' does not have access to any teams with an active membership"
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

    def platform_slug(mac)
      if mac
        'mac'
      else
        'ios'
      end
    end
    private :platform_slug

    #####################################################
    # @!group Apps
    #####################################################

    def apps(mac: false)
      paging do |page_number|
        r = request(:post, "account/#{platform_slug(mac)}/identifiers/listAppIds.action", {
          teamId: team_id,
          pageNumber: page_number,
          pageSize: page_size,
          sort: 'name=asc'
        })
        parse_response(r, 'appIds')
      end
    end

    def details_for_app(app)
      r = request(:post, "account/#{platform_slug(app.mac?)}/identifiers/getAppIdDetail.action", {
        teamId: team_id,
        appIdId: app.app_id
      })
      parse_response(r, 'appId')
    end

    def update_service_for_app(app, service)
      ensure_csrf(Spaceship::App)

      request(:post, service.service_uri, {
        teamId: team_id,
        displayId: app.app_id,
        featureType: service.service_id,
        featureValue: service.value
      })

      details_for_app(app)
    end

    def associate_groups_with_app(app, groups)
      ensure_csrf(Spaceship::AppGroup)

      request(:post, 'account/ios/identifiers/assignApplicationGroupToAppId.action', {
        teamId: team_id,
        appIdId: app.app_id,
        displayId: app.app_id,
        applicationGroups: groups.map(&:app_group_id)
      })

      details_for_app(app)
    end

    def create_app!(type, name, bundle_id, mac: false)
      # We moved the ensure_csrf to the top of this method
      # as we got some users with issues around creating new apps
      # https://github.com/fastlane/fastlane/issues/5813
      ensure_csrf(Spaceship::App)

      ident_params = case type.to_sym
                     when :explicit
                       {
                         type: 'explicit',
                         identifier: bundle_id,
                         push: 'on',
                         inAppPurchase: 'on',
                         gameCenter: 'on'
                       }
                     when :wildcard
                       {
                         type: 'wildcard',
                         identifier: bundle_id
                       }
                     end

      params = {
        name: name,
        teamId: team_id
      }

      params.merge!(ident_params)

      r = request(:post, "account/#{platform_slug(mac)}/identifiers/addAppId.action", params)
      parse_response(r, 'appId')
    end

    def delete_app!(app_id, mac: false)
      ensure_csrf(Spaceship::App)

      r = request(:post, "account/#{platform_slug(mac)}/identifiers/deleteAppId.action", {
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
      ensure_csrf(Spaceship::AppGroup)

      r = request(:post, 'account/ios/identifiers/addApplicationGroup.action', {
        name: name,
        identifier: group_id,
        teamId: team_id
      })
      parse_response(r, 'applicationGroup')
    end

    def delete_app_group!(app_group_id)
      ensure_csrf(Spaceship::AppGroup)

      r = request(:post, 'account/ios/identifiers/deleteApplicationGroup.action', {
        teamId: team_id,
        applicationGroup: app_group_id
      })
      parse_response(r)
    end

    #####################################################
    # @!group Devices
    #####################################################

    def devices(mac: false)
      paging do |page_number|
        r = request(:post, "account/#{platform_slug(mac)}/device/listDevices.action", {
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

    def create_device!(device_name, device_id, mac: false)
      ensure_csrf(Spaceship::Device)

      req = request(:post) do |r|
        r.url "https://developerservices2.apple.com/services/#{PROTOCOL_VERSION}/#{platform_slug(mac)}/addDevice.action"
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

    def certificates(types, mac: false)
      paging do |page_number|
        r = request(:post, "account/#{platform_slug(mac)}/certificate/listCertRequests.action", {
          teamId: team_id,
          types: types.join(','),
          pageNumber: page_number,
          pageSize: page_size,
          sort: 'certRequestStatusCode=asc'
        })
        parse_response(r, 'certRequests')
      end
    end

    def create_certificate!(type, csr, app_id = nil)
      ensure_csrf(Spaceship::Certificate)

      r = request(:post, 'account/ios/certificate/submitCertificateRequest.action', {
        teamId: team_id,
        type: type,
        csrContent: csr,
        appIdId: app_id # optional
      })
      parse_response(r, 'certRequest')
    end

    def download_certificate(certificate_id, type, mac: false)
      { type: type, certificate_id: certificate_id }.each { |k, v| raise "#{k} must not be nil" if v.nil? }

      r = request(:get, "account/#{platform_slug(mac)}/certificate/downloadCertificateContent.action", {
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

    def revoke_certificate!(certificate_id, type, mac: false)
      ensure_csrf(Spaceship::Certificate)

      r = request(:post, "account/#{platform_slug(mac)}/certificate/revokeCertificate.action", {
        teamId: team_id,
        certificateId: certificate_id,
        type: type
      })
      parse_response(r, 'certRequests')
    end

    #####################################################
    # @!group Provisioning Profiles
    #####################################################

    def provisioning_profiles(mac: false)
      req = request(:post) do |r|
        r.url "https://developerservices2.apple.com/services/#{PROTOCOL_VERSION}/#{platform_slug(mac)}/listProvisioningProfiles.action"
        r.params = {
          teamId: team_id,
          includeInactiveProfiles: true,
          onlyCountLists: true
        }
      end

      parse_response(req, 'provisioningProfiles')
    end

    def provisioning_profile_details(provisioning_profile_id: nil, mac: false)
      r = request(:post, "account/#{platform_slug(mac)}/profile/getProvisioningProfile.action", {
        teamId: team_id,
        provisioningProfileId: provisioning_profile_id
      })
      parse_response(r, 'provisioningProfile')
    end

    def create_provisioning_profile!(name, distribution_method, app_id, certificate_ids, device_ids, mac: false, sub_platform: nil)
      ensure_csrf(Spaceship::ProvisioningProfile) do
        fetch_csrf_token_for_provisioning
      end

      params = {
        teamId: team_id,
        provisioningProfileName: name,
        appIdId: app_id,
        distributionType: distribution_method,
        certificateIds: certificate_ids,
        deviceIds: device_ids
      }
      params[:subPlatform] = sub_platform if sub_platform

      r = request(:post, "account/#{platform_slug(mac)}/profile/createProvisioningProfile.action", params)
      parse_response(r, 'provisioningProfile')
    end

    def download_provisioning_profile(profile_id, mac: false)
      ensure_csrf(Spaceship::ProvisioningProfile) do
        fetch_csrf_token_for_provisioning
      end

      r = request(:get, "account/#{platform_slug(mac)}/profile/downloadProfileContent", {
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

    def delete_provisioning_profile!(profile_id, mac: false)
      ensure_csrf(Spaceship::ProvisioningProfile) do
        fetch_csrf_token_for_provisioning
      end

      r = request(:post, "account/#{platform_slug(mac)}/profile/deleteProvisioningProfile.action", {
        teamId: team_id,
        provisioningProfileId: profile_id
      })
      parse_response(r)
    end

    def repair_provisioning_profile!(profile_id, name, distribution_method, app_id, certificate_ids, device_ids, mac: false)
      ensure_csrf(Spaceship::ProvisioningProfile) do
        fetch_csrf_token_for_provisioning
      end

      r = request(:post, "account/#{platform_slug(mac)}/profile/regenProvisioningProfile.action", {
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

    # We need a custom way to fetch the csrf token for the provisioning profile requests, since
    # we use a separate API endpoint (host of Xcode API) to fetch the provisioning profiles
    # All we do is fetch one profile (if exists) to get a valid csrf token with its time stamp
    # This method is being called from all requests that modify, create or downloading provisioning
    # profiles.
    # Source https://github.com/fastlane/fastlane/issues/5903
    def fetch_csrf_token_for_provisioning(mac: false)
      req = request(:post) do |r|
        r.url "https://developer.apple.com/services-account/#{PROTOCOL_VERSION}/account/#{platform_slug(mac)}/profile/listProvisioningProfiles.action"
        r.params = {
          teamId: team_id,
          pageSize: 1,
          pageNumber: 1,
          sort: "name=asc"
        }
      end

      parse_response(req, 'provisioningProfiles')
      return nil
    end

    private

    # This is a cache of entity type (App, AppGroup, Certificate, Device) to csrf_tokens
    def csrf_cache
      @csrf_cache || {}
    end

    # Ensures that there are csrf tokens for the appropriate entity type
    # Relies on store_csrf_tokens to set csrf_tokens to the appropriate value
    # then stores that in the correct place in cache
    # This method also takes a block, if you want to send a custom request, instead of
    # calling `.all` on the given klass. This is used for provisioning profiles.
    def ensure_csrf(klass)
      if csrf_cache[klass]
        self.csrf_tokens = csrf_cache[klass]
        return
      end

      self.csrf_tokens = nil

      # If we directly create a new resource (e.g. app) without querying anything before
      # we don't have a valid csrf token, that's why we have to do at least one request
      block_given? ? yield : klass.all

      # Update 18th August 2016
      # For some reason, we have to query the resource twice to actually get a valid csrf_token
      # I couldn't find out why, the first response does have a valid Set-Cookie header
      # But it still needs this second request
      block_given? ? yield : klass.all

      csrf_cache[klass] = self.csrf_tokens
    end
  end
  # rubocop:enable Metrics/ClassLength
end
