require 'faraday' # HTTP Client
require 'logger'
require 'faraday_middleware'
require 'spaceship/ui'
require 'spaceship/helper/plist_middleware'
require 'spaceship/helper/net_http_generic_request'

if ENV["DEBUG"]
  require 'openssl'
  # this has to be on top of this file, since the value can't be changed later
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
end

module Spaceship
  class Client
    PROTOCOL_VERSION = "QH65B2"

    attr_reader :client
    attr_accessor :cookie

    # The logger in which all requests are logged
    # /tmp/spaceship.log by default
    attr_accessor :logger

    # Invalid user credentials were provided
    class InvalidUserCredentialsError < StandardError; end

    class UnexpectedResponse < StandardError; end

    # Authenticates with Apple's web services. This method has to be called once
    # to generate a valid session. The session will automatically be used from then
    # on.
    #
    # This method will automatically use the username from the Appfile (if available)
    # and fetch the password from the Keychain (if available)
    #
    # @param user (String) (optional): The username (usually the email address)
    # @param password (String) (optional): The password
    #
    # @raise InvalidUserCredentialsError: raised if authentication failed
    #
    # @return (Spaceship::Client) The client the login method was called for
    def self.login(user = nil, password = nil)
      instance = self.new
      if instance.login(user, password)
        instance
      else
        raise InvalidUserCredentialsError.new
      end
    end

    def initialize
      @client = Faraday.new("https://developer.apple.com/services-account/#{PROTOCOL_VERSION}/", ssl: {version: :TLSv1}) do |c|
        c.response :json, content_type: /\bjson$/
        c.response :xml, content_type: /\bxml$/
        c.response :plist, content_type: /\bplist$/
        c.adapter Faraday.default_adapter

        if ENV['DEBUG']
          # for debugging only
          # This enables tracking of networking requests using Charles Web Proxy
          c.response :logger
          c.proxy "https://127.0.0.1:8888"
        end
      end
    end

    # Fetches the latest API Key from the Apple Dev Portal
    def api_key
      cache_path = "/tmp/spaceship_api_key.txt"
      cached = File.read(cache_path) rescue nil
      return cached if cached

      landing_url = "https://developer.apple.com/membercenter/index.action"
      logger.info("GET: " + landing_url)
      headers = @client.get(landing_url).headers
      results = headers['location'].match(/.*appIdKey=(\h+)/)
      if results.length > 1
        api_key = results[1]
        File.write(cache_path, api_key)
        return api_key
      else
        raise "Could not find latest API Key from the Dev Portal"
      end
    end

    # The logger in which all requests are logged
    # /tmp/spaceship.log by default
    def logger
      unless @logger
        if $verbose || ENV["VERBOSE"]
          @logger = Logger.new(STDOUT)
        else
          # Log to file by default
          path = "/tmp/spaceship.log"
          puts "Logging spaceship web requests to '#{path}'"
          @logger = Logger.new(path)
        end

        @logger.formatter = proc do |severity, datetime, progname, msg|
          string = "[#{datetime.strftime('%H:%M:%S')}]: #{msg}\n"
        end
      end

      @logger
    end

    #####################################################
    # @!group Automatic Paging
    #####################################################

    # The page size we want to request, defaults to 500
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

    #####################################################
    # @!group Login and Team Selection
    #####################################################

    # Authenticates with Apple's web services. This method has to be called once
    # to generate a valid session. The session will automatically be used from then
    # on.
    #
    # This method will automatically use the username from the Appfile (if available)
    # and fetch the password from the Keychain (if available)
    #
    # @param user (String) (optional): The username (usually the email address)
    # @param password (String) (optional): The password
    #
    # @raise InvalidUserCredentialsError: raised if authentication failed
    #
    # @return (Spaceship::Client) The client the login method was called for
    def login(user = nil, password = nil)
      if user.to_s.empty? or password.to_s.empty?
        require 'credentials_manager'
        data = CredentialsManager::PasswordManager.shared_manager(user, false)
        user ||= data.username
        password ||= data.password
      end

      if user.to_s.empty? or password.to_s.empty?
        raise InvalidUserCredentialsError.new("No login data provided")
      end

      response = request(:post, "https://idmsa.apple.com/IDMSWebAuth/authenticate", {
        appleId: user,
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

    # @return (Bool) Do we have a valid session?
    def session?
      !!@cookie
    end

    # @return (Array) A list of all available teams
    def teams
      r = request(:post, 'account/listTeams.action')
      parse_response(r, 'teams')
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

    #####################################################
    # @!group Apps
    #####################################################

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

    def details_for_app(app)
      r = request(:post, 'account/ios/identifiers/getAppIdDetail.action', {
        teamId: team_id,
        appIdId: app.app_id
      })
      parse_response(r, 'appId')
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

    #####################################################
    # @!group Devices
    #####################################################

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

    def create_device!(device_name, device_id)
      r = request(:post) do |r|
        r.url "https://developerservices2.apple.com/services/#{PROTOCOL_VERSION}/ios/addDevice.action"
        r.params = {
          teamId: team_id,
          deviceNumber: device_id,
          name: device_name
        }
      end

      parse_response(r, 'device')
    end

    #####################################################
    # @!group Certificates
    #####################################################

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
        teamId: team_id,
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

    #####################################################
    # @!group Provisioning Profiles
    #####################################################

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
        certificateIds: certificate_ids.first, # we are most of the times only allowed to pass one
        deviceIds: device_ids
      })

      parse_response(r, 'provisioningProfile')
    end

    private
      # Is called from `parse_response` to store the latest csrf_token (if available)
      def store_csrf_tokens(response)
        if response and response.headers
          tokens = response.headers.select { |k, v| %w[csrf csrf_ts].include?(k) }
          if tokens and not tokens.empty?
            @csrf_tokens = tokens
          end
        end
      end

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

        # Before encoding the parameters, log them
        log_request(method, url_or_path, params)

        # form-encode the params only if there are params, and the block is not supplied.
        # this is so that certain requests can be made using the block for more control
        if method == :post && params && !block_given?
          params, headers = encode_params(params, headers)
        end

        response = send_request(method, url_or_path, params, headers, &block)

        log_response(method, url_or_path, response)

        return response
      end

      def log_request(method, url, params)
        params_to_log = Hash(params).dup # to also work with nil
        params_to_log.delete(:accountPassword)
        params_to_log = params_to_log.collect do |key, value|
          "{#{key}: #{value}}"
        end
        logger.info("#{method.upcase}: #{url} #{params_to_log.join(', ')}")
      end

      def log_response(method, url, response)
        logger.debug("#{method.upcase}: #{url}: #{response.body}")
      end

      # Actually sends the request to the remote server
      # Automatically retries the request up to 3 times if something goes wrong
      def send_request(method, url_or_path, params, headers, &block)
        tries ||= 5

        return @client.send(method, url_or_path, params, headers, &block)

      rescue Faraday::Error::TimeoutError => ex # New Faraday version: Faraday::TimeoutError => ex
        unless (tries -= 1).zero?
          sleep 3
          retry
        end

        raise ex # re-raise the exception
      end

      def parse_response(response, expected_key = nil)
        if expected_key
          content = response.body[expected_key]
        else
          content = response.body
        end

        if content == nil
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
