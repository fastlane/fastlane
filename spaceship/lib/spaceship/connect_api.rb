require 'spaceship/connect_api/model'
require 'spaceship/connect_api/response'
require 'spaceship/connect_api/token'

require 'spaceship/connect_api/provisioning/provisioning'
require 'spaceship/connect_api/testflight/testflight'
require 'spaceship/connect_api/users/users'

require 'spaceship/connect_api/models/bundle_id'
require 'spaceship/connect_api/models/certificate'
require 'spaceship/connect_api/models/device'
require 'spaceship/connect_api/models/profile'

require 'spaceship/connect_api/models/user'

require 'spaceship/connect_api/models/app'
require 'spaceship/connect_api/models/beta_app_localization'
require 'spaceship/connect_api/models/beta_build_localization'
require 'spaceship/connect_api/models/beta_build_metric'
require 'spaceship/connect_api/models/beta_app_review_detail'
require 'spaceship/connect_api/models/beta_app_review_submission'
require 'spaceship/connect_api/models/beta_group'
require 'spaceship/connect_api/models/beta_tester'
require 'spaceship/connect_api/models/beta_tester_metric'
require 'spaceship/connect_api/models/build'
require 'spaceship/connect_api/models/build_delivery'
require 'spaceship/connect_api/models/build_beta_detail'
require 'spaceship/connect_api/models/pre_release_version'

module Spaceship
  module ConnectAPI
    @token = nil

    def self.token=(token)
      @token = token
    end

    def self.token
      @token
    end

    def self.method_missing(method_sym, *arguments, &block)
      if MethodCollector.respond_to?(method_sym)
        MethodCollector.send(method_sym, *arguments, &block)
      else
        super
      end
    end

    class MethodCollector
      extend Spaceship::ConnectAPI::Provisioning
      extend Spaceship::ConnectAPI::TestFlight
      extend Spaceship::ConnectAPI::Users
    end
  end
end
