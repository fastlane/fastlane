require 'faraday' # HTTP Client
require 'faraday_middleware'
require 'faraday_middleware/response_middleware'
require 'nokogiri'
require 'pry' # TODO: Remove

require 'singleton'

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
        #for debugging:
        #c.response :logger
        #c.proxy "http://localhost:8080"
      end
    end

    def api_key
      page = @client.get("https://developer.apple.com/devcenter/ios/index.action").body
      html = Nokogiri::HTML(page)
      link = html.css('a[href*=IDMSWebAuth]')[0]
      href = link['href']
      params = CGI.parse(href)['appIdKey']
      params[0]
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
      response = request(:post, "account/ios/identifiers/listAppIds.action", {
        teamId: team_id,
        pageNumber: 1,
        pageSize: 500,
        sort: "name=asc"
      })
      response.body['appIds']
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

    def certificates(types = [])
      response = request(:post, 'account/ios/certificate/listCertRequests.action', {
        teamId: team_id,
        types: types.join(','),
        pageNumber: 1,
        pageSize: 500,
        sort: 'certRequestStatusCode=asc'
      })
      response.body['certRequests']
    end

    def download_certificate(certificate_id, type)
      response = request(:post, 'https://developer.apple.com/account/ios/certificate/certificateContentDownload.action', {
        displayId: certificate_id,
        type: type
      })
      response.body
    end
=begin
    def revoke_certificate
    end

    def provisioning_profiles
    end

    def provisioning_profile(bundle_id, distribution_method)
    end

    def generate_provisioning_profile(profile, distribution_method, device_ids, certificate)
    end
=end
    private
      def request(method, url_or_path, params = {}, headers = {}, &block)
        if session?
          headers.merge!({'Cookie' => cookie})
          @client.send(method, url_or_path, params, headers, &block)
        else
          @client.send(method, url_or_path, params, headers, &block)
        end
      end
  end
end
