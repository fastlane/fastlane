require 'faraday' # HTTP Client
require 'faraday_middleware'
require 'spaceship/ui'
require 'spaceship/helper/plist_middleware'
require 'spaceship/helper/net_http_generic_request'

if ENV['DEBUG']
  require 'pry' # TODO: Remove
  require 'openssl'
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
end


module Spaceship
  class Client
    PROTOCOL_VERSION = "QH65B2"

    attr_reader :client
    attr_accessor :cookie

    class InvalidUserCredentialsError < StandardError; end
    class UnexpectedResponse < StandardError; end

    def self.login(username = nil, password = nil)
      instance = self.new
      if instance.login(username, password)
        instance
      else
        raise InvalidUserCredentialsError.new
      end
    end

    def initialize
      @client = Faraday.new("https://developer.apple.com/services-account/#{PROTOCOL_VERSION}/") do |c|
        c.response :json, :content_type => /\bjson$/
        c.response :xml, :content_type => /\bxml$/
        c.response :plist, :content_type => /\bplist$/
        c.adapter Faraday.default_adapter

        if ENV['DEBUG']
          # for debugging:
          c.response :logger
          c.proxy "https://127.0.0.1:8888"
        end
      end
    end

    def api_key
      page = @client.get("https://developer.apple.com/devcenter/ios/index.action").body
      if page =~ %r{<a href="https://idmsa.apple.com/IDMSWebAuth/login\?.*appIdKey=(\h+)}
        return $1
      end
    end

    # Automatic paging

    def page_size
      @page_size ||= 500
    end

    # Handles the paging for you... for free
    # Just pass a block and use the parameter as page number
    def paging
      page = 0
      results = []
      loop do
        page += 1
        current = yield(page)

        results = results + current
        
        break if ((current || []).count < page_size) # no more results
      end

      return results
    end

    ##
    # perform login procedure. this sets a cookie that will be used in subsequent requests
    # raises InvalidUserCredentialsError if authentication failed.
    #
    # returns Spaceship::Client
    def login(username = nil, password = nil)
      if username.to_s.empty? or password.to_s.empty?
        raise InvalidUserCredentialsError.new("No login data provided")
      end

      response = request(:post, "https://idmsa.apple.com/IDMSWebAuth/authenticate", {
        appleId: username,
        accountPassword: password,
        appIdKey: api_key
      })

      if response['Set-Cookie'] =~ /myacinfo=(\w+);/
        @cookie = "myacinfo=#{$1};"
        return @client
      else
        # User Credentials are wrong
        raise InvalidUserCredentialsError.new(response)
      end
    end

    def session?
      !!@cookie
    end

    def teams
      r = request(:post, 'account/listTeams.action')
      parse_response(r, 'teams')
    end

    def team_id
      return ENV['FASTLANE_TEAM_ID'] if ENV['FASTLANE_TEAM_ID']
      return @current_team_id if @current_team_id

      if teams.count > 1
        Helper.log.warn "The current user is in #{teams.count} teams. Pass a team ID or call `select_team` to choose a team. Using the first one for now."
      end
      @current_team_id ||= teams[0]['teamId']
    end

    def select_team
      @current_team_id = self.UI.select_team
    end

    def current_team_id=(team_id)
      @current_team_id = team_id
    end

    def apps
      paging do |page_number|
        r = request(:post, 'account/ios/identifiers/listAppIds.action', {
          teamId: team_id,
          pageNumber: page_number,
          pageSize: page_size,
          sort: 'name=asc'
        })
        parse_response(r, 'appIds')
      end
    end

    def create_app!(type, name, bundle_id)
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

      r = request(:post, 'account/ios/identifiers/addAppId.action', params)
      parse_response(r, 'appId')
    end

    def delete_app!(app_id)
      r = request(:post, 'account/ios/identifiers/deleteAppId.action', {
        teamId: team_id,
        appIdId: app_id
      })
      parse_response(r)
    end

    def devices
      paging do |page_number|
        r = request(:post, 'account/ios/device/listDevices.action', {
          teamId: team_id,
          pageNumber: page_number,
          pageSize: page_size,
          sort: 'name=asc'
        })
        parse_response(r, 'devices')
      end
    end

    def create_device(device_name, device_id)
      request(:post) do |r|
        r.url "https://developerservices2.apple.com/services/#{PROTOCOL_VERSION}/ios/addDevice.action"
        r.params = {
          teamId: team_id,
          deviceNumber: device_id,
          name: device_name
        }
      end
    end

    def certificates(types)
      paging do |page_number|
        r = request(:post, 'account/ios/certificate/listCertRequests.action', {
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
      r = request(:post, 'account/ios/certificate/submitCertificateRequest.action', {
        teamId: team_id,
        type: type,
        csrContent: csr,
        appIdId: app_id  #optional
      })
      parse_response(r, 'certRequest')
    end

    def download_certificate(certificate_id, type)
      {type: type, certificate_id: certificate_id}.each { |k, v| raise "#{k} must not be nil" if v.nil? }

      r = request(:post, 'https://developer.apple.com/account/ios/certificate/certificateContentDownload.action', {
        displayId: certificate_id,
        type: type
      })
      parse_response(r)
    end

    def revoke_certificate!(certificate_id, type)
      r = request(:post, 'account/ios/certificate/revokeCertificate.action', {
        teamId: team_id,
        certificateId: certificate_id,
        type: type
      })
      parse_response(r, 'certRequests')
    end

    def provisioning_profiles
      r = request(:post) do |r|
        r.url "https://developerservices2.apple.com/services/#{PROTOCOL_VERSION}/ios/listProvisioningProfiles.action"
        r.params = {
          teamId: team_id,
          includeInactiveProfiles: true,
          onlyCountLists: true,
        }
      end

      parse_response(r, 'provisioningProfiles')
    end

    def provisioning_profile(profile_id)
      r = request(:post, 'account/ios/profile/getProvisioningProfile.action', {
        teamId: team_id,
        includeInactiveProfiles: true,
        onlyCountLists: true,
        provisioningProfileId: profile_id
      })
      parse_response(r, 'provisioningProfile')
    end

    def create_provisioning_profile!(name, distribution_method, app_id, certificate_ids, device_ids)
      r = request(:post, 'account/ios/profile/createProvisioningProfile.action', {
        teamId: team_id,
        provisioningProfileName: name,
        appIdId: app_id,
        distributionType: distribution_method,
        certificateIds: certificate_ids,
        deviceIds: device_ids
      })
      parse_response(r, 'provisioningProfile')
    end

    def download_provisioning_profile(profile_id)
      r = request(:get, 'https://developer.apple.com/account/ios/profile/profileContentDownload.action', {
        teamId: team_id,
        displayId: profile_id
      })
      parse_response(r)
    end

    def delete_provisioning_profile!(profile_id)
      r = request(:post, 'account/ios/profile/deleteProvisioningProfile.action', {
        teamId: team_id,
        provisioningProfileId: profile_id
      })
      parse_response(r)
    end

    def repair_provisioning_profile!(profile_id, name, distribution_method, app_id, certificate_ids, device_ids)
      r = request(:post, 'account/ios/profile/regenProvisioningProfile.action', {
        teamId: team_id,
        provisioningProfileId: profile_id,
        provisioningProfileName: name,
        appIdId: app_id,
        distributionType: distribution_method,
        certificateIds: certificate_ids,
        deviceIds: device_ids
      })

      parse_response(r, 'provisioningProfile')
    end

    private
      # Is called from `parse_response` to strore 
      def store_csrf_tokens(response)
        if response and response.headers
          tokens = response.headers.select { |k, v| %w[csrf csrf_ts].include?(k) }
          if tokens and not tokens.empty?
            @csrf_tokens = tokens
          end
        end
      end
      ##
      # memoize the last csrf tokens from responses
      def csrf_tokens
        @csrf_tokens || {}
      end

      def request(method, url_or_path = nil, params = nil, headers = {}, &block)
        if session?
          headers.merge!({'Cookie' => cookie})
          headers.merge!(csrf_tokens)
        end
        headers.merge!({'User-Agent' => 'spaceship'})

        # form-encode the params only if there are params, and the block is not supplied.
        # this is so that certain requests can be made using the block for more control
        if method == :post && params && !block_given?
          params, headers = encode_params(params, headers)
        end

        @client.send(method, url_or_path, params, headers, &block)
      end

      def parse_response(response, expected_key = nil)
        if expected_key
          content = response.body[expected_key]
        else
          content = response.body
        end

        if content.nil?
          raise UnexpectedResponse.new(response.body)
        else
          store_csrf_tokens(response)
          content
        end
      end

      def encode_params(params, headers)
        params = Faraday::Utils::ParamsHash[params].to_query
        headers = {'Content-Type' => 'application/x-www-form-urlencoded'}.merge(headers)
        return params, headers
      end
  end
end
