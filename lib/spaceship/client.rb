require 'faraday' # HTTP Client
require 'faraday_middleware'
require 'faraday_middleware/response_middleware'

require 'singleton'

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
  module SharedClient
    def client
      Client.instance
    end
  end

  class Client
    PROTOCOL_VERSION = "QH65B2"
    include Singleton

    attr_reader :client
    attr_accessor :cookie

    def self.login(username = nil, password = nil)
      username ||= ENV['DELIVER_USER']
      password ||= ENV['DELIVER_PASSWORD']

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

    def login(username, password)
      response = @client.post("https://idmsa.apple.com/IDMSWebAuth/authenticate", {
        appleId: username,
        accountPassword: password,
        appIdKey: api_key
      })

      if response['Set-Cookie'] =~ /myacinfo=(\w+);/
        @cookie = "myacinfo=#{$1};"
      end
    end

    def cookie
      return @cookie if @cookie

      raise 'No session found. Please login with `Spaceship::Client.login(username, password)`'
    end

    def session?
      !!@cookie
    end

    def teams
      response = request(:post, 'account/listTeams.action')
      response.body['teams']
    end

    def team_id
      @current_team_id ||= teams[0]['teamId']
    end

    def current_team_id=(team_id)
      @current_team_id = team_id
    end

    def apps
      response = request(:post, 'account/ios/identifiers/listAppIds.action', {
        teamId: team_id,
        pageNumber: 1,
        pageSize: 500,
        sort: 'name=asc'
      })
      response.body['appIds']
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

      response = request(:post, 'account/ios/identifiers/addAppId.action', params)
      response.body['appId']
    end

    #this might be nice to have
    #def validate_app(same params as above)
    #account/ios/identifiers/validateAppId.action
    #end

    def delete_app(app_id)
      response = request(:post, 'account/ios/identifiers/deleteAppId.action', {
        teamId: team_id,
        appIdId: app_id
      })
      response.body
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
      response = request(:post, 'account/ios/certificate/revokeCertificate.action', {
        teamId: team_id,
        certificateId: certificate_id,
        type: type
      })
      response.body['certRequests']
    end

    def provisioning_profiles
      response = request(:post, 'account/ios/profile/listProvisioningProfiles.action', {
        teamId: team_id,
        includeInactiveProfiles: true,
        onlyCountLists: true,
        search: nil,
        pageSize: 500,
        pageNumber: 1,
        sort: 'name=asc'
      })
      response.body['provisioningProfiles']
    end

    def provisioning_profile(profile_id, distribution_method)
      response = request(:post, 'account/ios/profile/getProvisioningProfile.action', {
        teamId: team_id,
        includeInactiveProfiles: true,
        onlyCountLists: true,
        provisioningProfileId: profile_id
      })
      response.body['provisioningProfile']
    end

    def download_provisioning_profile(profile_id)
      response = request(:get, 'https://developer.apple.com/account/ios/profile/profileContentDownload.action', {
        displayId: profile_id
      })
      response.body
    end

    def generate_provisioning_profile(profile, distribution_method, device_ids, certificate)
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
  end
end
