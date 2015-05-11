require 'faraday' # HTTP Client
require 'faraday_middleware'
require 'faraday_middleware/response_middleware'

if ENV['DEBUG']
  require 'pry' # TODO: Remove
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
end

module FaradayMiddleware
  class PlistMiddleware < ResponseMiddleware
    dependency do
      require 'plist' unless defined?(::Plist)
    end

    define_parser do |body|
      Plist::parse_xml(body)
    end
  end
end

Faraday::Response.register_middleware(:plist => FaradayMiddleware::PlistMiddleware)

module Spaceship
  class Client
    PROTOCOL_VERSION = "QH65B2"

    attr_reader :client
    attr_accessor :cookie

    class NotAuthenticatedError < StandardError; end
    class UnexpectedResponse < StandardError; end

    def self.login(username, password)
      instance = self.new
      instance.login(username, password)
      instance
    end

    def initialize
      @client = Faraday.new("https://developer.apple.com/services-account/#{PROTOCOL_VERSION}/") do |c|
        c.response :json, :content_type => /\bjson$/
        c.response :xml, :content_type => /\bxml$/
        c.response :plist, :content_type => /\bplist$/
        c.request :url_encoded
        c.adapter Faraday.default_adapter #can be Excon

        if ENV['DEBUG']
          #for debugging:
          c.response :logger
          c.proxy "http://localhost:8080"
        end
      end
    end

    def api_key
      page = @client.get("https://developer.apple.com/devcenter/ios/index.action").body
      if page =~ %r{<a href="https://idmsa.apple.com/IDMSWebAuth/login\?.*appIdKey=(\h+)}
        return $1
      end
    end

    ##
    # perform login procedure. this sets a cookie that will be used in subsequent requests
    # raises NotAuthenticatedError if authentication failed.
    #
    # returns Spaceship::Client
    def login(username, password)
      response = @client.post("https://idmsa.apple.com/IDMSWebAuth/authenticate", {
        appleId: username,
        accountPassword: password,
        appIdKey: api_key
      })

      if response['Set-Cookie'] =~ /myacinfo=(\w+);/
        @cookie = "myacinfo=#{$1};"
        return @client
      end

      raise NotAuthenticatedError.new(response)
    end

    def session?
      !!@cookie
    end

    def teams
      request(:post, 'account/listTeams.action')
      return_response('teams')
    end

    def team_id
      @current_team_id ||= teams[0]['teamId']
    end

    def current_team_id=(team_id)
      @current_team_id = team_id
    end

    def apps
      request(:post, 'account/ios/identifiers/listAppIds.action', {
        teamId: team_id,
        pageNumber: 1,
        pageSize: 500,
        sort: 'name=asc'
      })
      return_response('appIds')
    end

    def create_app(type, name, bundle_id)
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

      request(:post, 'account/ios/identifiers/addAppId.action', params)
      return_response('appId')
    end

    #this might be nice to have
    #def validate_app(same params as above)
    #account/ios/identifiers/validateAppId.action
    #end

    def delete_app(app_id)
      request(:post, 'account/ios/identifiers/deleteAppId.action', {
        teamId: team_id,
        appIdId: app_id
      })
      return_response
    end

    def devices
      response = request(:post, 'account/ios/device/listDevices.action', {
        teamId: team_id,
        pageNumber: 1,
        pageSize: 500,
        sort: 'name=asc'
      })
      response.body['devices']
    end

    def certificates(types)
      response = request(:post, 'account/ios/certificate/listCertRequests.action', {
        teamId: team_id,
        types: types.join(','),
        pageNumber: 1,
        pageSize: 500,
        sort: 'certRequestStatusCode=asc'
      })
      response.body['certRequests']
    end

    def create_certificate(type, csr, app_id = nil)
      response = request(:post, 'account/ios/certificate/submitCertificateRequest.action', {
        teamId: team_id,
        type: type,
        csrContent: csr,
        appIdId: app_id  #optional
      })
      response.body['certRequest']
    end

    def download_certificate(certificate_id, type)
      response = request(:post, 'https://developer.apple.com/account/ios/certificate/certificateContentDownload.action', {
        displayId: certificate_id,
        type: type
      })
      response.body
    end

    def revoke_certificate(certificate_id, type)
      request(:post, 'account/ios/certificate/revokeCertificate.action', {
        teamId: team_id,
        certificateId: certificate_id,
        type: type
      })
      return_response('certRequests')
    end

    def provisioning_profiles
      request(:post, 'account/ios/profile/listProvisioningProfiles.action', {
        teamId: team_id,
        includeInactiveProfiles: true,
        onlyCountLists: true,
        search: nil,
        pageSize: 500,
        pageNumber: 1,
        sort: 'name=asc'
      })
      return_response('provisioningProfiles')
    end

    def provisioning_profile(profile_id)
      request(:post, 'account/ios/profile/getProvisioningProfile.action', {
        teamId: team_id,
        includeInactiveProfiles: true,
        onlyCountLists: true,
        provisioningProfileId: profile_id
      })
      return_response('provisioningProfile')
    end

    def create_provisioning_profile(name, distribution_method, app_id, certificate_ids, device_ids)
      request(:post, 'account/ios/profile/createProvisioningProfile.action', {
        teamId: team_id,
        provisioningProfileName: name,
        appIdId: app_id,
        distributionType: distribution_method,
        certificateIds: certificate_ids,
        deviceIds: device_ids,
      })
      return_response('provisioningProfile')
    end

    def download_provisioning_profile(profile_id)
      response = request(:get, 'https://developer.apple.com/account/ios/profile/profileContentDownload.action', {
        teamId: team_id,
        displayId: profile_id
      })
      response.body
    end

    def delete_provisioning_profile(profile_id)
      response = request(:post, 'account/ios/profile/deleteProvisioningProfile.action', {
        teamId: team_id,
        provisioningProfileId: profile_id
      })
      response.body
    end

    private
      ##
      # memoize the last csrf tokens from responses
      def csrf_tokens
        return {} unless @last_response

        tokens = @last_response.headers.select{|k,v| %w[csrf csrf_ts].include?(k) }
        if tokens.empty? && @crsf_tokens && !@csrf_tokens.empty?
          @csrf_tokens
        else
          @csrf_tokens = tokens
        end
      end

      def request(method, url_or_path, params = {}, headers = {}, &block)
        if session?
          headers.merge!({'Cookie' => cookie})
          headers.merge!(csrf_tokens)
        end
        @last_response = @client.send(method, url_or_path, params, headers, &block)
      end

      def return_response(expected_key)
        content = @last_response.body[expected_key]
        if content.nil?
          raise UnexpectedResponse.new(@last_response.body)
        else
          content
        end
      end
  end
end
