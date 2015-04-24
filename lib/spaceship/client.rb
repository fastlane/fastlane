require 'faraday' # HTTP Client
require 'faraday_middleware'
require 'faraday_middleware/response_middleware'
require 'nokogiri'
require 'pry' # TODO: Remove

require 'spaceship/urls'
require 'spaceship/helper'
require 'spaceship/profile_types'
require 'spaceship/login/login'
require 'spaceship/apps/apps'
require 'spaceship/devices/devices'
require 'spaceship/certificates/certificates'
require 'spaceship/provisioning_profiles/provisioning_profiles'
require 'singleton'

module FaradayMiddleware
  class PlistMiddleware < ResponseMiddleware
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
    include Singleton

    attr_accessor :cookie

    def initialize
      @client = Faraday.new do |c|
        c.response :json, :content_type => /\bjson$/
        c.response :xml, :content_type => /\bxml$/
        c.response :plist, :content_type => /\bx-plist$/
        c.request :url_encoded
        c.adapter Faraday.default_adapter #can be Excon
      end
    end

    def api_key
      page = @client.get(URL_LOGIN_LANDING_PAGE).body
      html = Nokogiri::HTML(page)
      link = html.css('a[href*=IDMSWebAuth]')[0]
      href = link['href']
      params = CGI.parse(href)['appIdKey']
      params[0]
    end

    def login(username, password)
      response = @client.post(URL_AUTHENTICATE,{
          appleId: username,
          accountPassword: password,
          appIdKey: api_key
        })

      @cookie = response['Set-Cookie']
    end

    def teams
      response = @client.post(URL_LIST_TEAMS, {}, {'Cookie' => cookie})
      xml = Plist::parse_xml(response.body)
      xml['teams']
    end

    def team_id
      @current_team_id ||= teams[0]['teamId']
    end

    def current_team_id=(team_id)
      @current_team_id = team_id
    end

    def apps
      response = @client.post(URL_APP_IDS, {
        teamId: team_id,
        pageNumber: 1,
        pageSize: 5000,
        sort: "name=asc"
      },
      {'Cookie' => cookie})
      response.body['appIds']
    end

    #this should probably be in the model.
    def app(bundle_id)
      apps.select do |app|
        app['appIdId'] == bundle_id
      end.first
    end

    def devices
      response = @client.post(URL_LIST_DEVICES, {
        teamId: team_id
      }, {
        Cookie: cookie
      })
      response.body['devices']
    end

    def certificates(types = nil)
    end

    def download_certificate(certificate_id, type)
    end

    def revoke_certificate
    end

    def provisioning_profiles
    end

    def provisioning_profile(bundle_id, distribution_method)
    end

    def generate_provisioning_profile(profile, distribution_method, device_ids, certificate)
    end
  end
end
