require 'spaceship/connect_api/model'
require 'spaceship/connect_api/response'
require 'spaceship/connect_api/token'

require 'spaceship/connect_api/provisioning/provisioning'
require 'spaceship/connect_api/testflight/testflight'
require 'spaceship/connect_api/users/users'

require 'spaceship/connect_api/models/bundle_id_capability'
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
  class ConnectAPI
    extend Spaceship::ConnectAPI::Provisioning
    extend Spaceship::ConnectAPI::TestFlight
    extend Spaceship::ConnectAPI::Users

    @token = nil

    class << self
      attr_writer(:token)
    end

    class << self
      attr_reader :token
    end
  end
end
