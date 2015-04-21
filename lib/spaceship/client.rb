require 'excon' # HTTP Client
require 'pry' # TODO: Remove

require 'spaceship/urls'
require 'spaceship/helper'
require 'spaceship/profile_types'
require 'spaceship/login/login'
require 'spaceship/apps/apps'
require 'spaceship/devices/devices'
require 'spaceship/certificates/certificates'
require 'spaceship/provisioning_profiles/provisioning_profiles'

module Spaceship
  class Client
    attr_accessor :myacinfo
    attr_accessor :team_id

    def initialize(user = nil, password = nil)
      login(user, password)
    end

    def request(url, params = {})
      @connection = Excon.new(url, params)
      @connection.data[:middlewares] << Excon::Middleware::Decompress

      self
    end

    def with_auth
      @connection.data[:headers]['Cookie'] = 'myacinfo=' + @myacinfo

      self
    end

    Excon::HTTP_VERBS.each do |verb|
      define_method(verb) do |&block|
        @connection.request(method: verb, &block)
      end
    end
  end
end
