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
  end
end