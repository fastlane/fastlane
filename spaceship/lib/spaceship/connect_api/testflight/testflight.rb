require 'spaceship/connect_api/testflight/client'
require 'spaceship/connect_api/testflight/base'

require 'spaceship/connect_api/testflight/models/app'
require 'spaceship/connect_api/testflight/models/beta_app_localization'
require 'spaceship/connect_api/testflight/models/beta_build_localization'
require 'spaceship/connect_api/testflight/models/beta_build_metric'
require 'spaceship/connect_api/testflight/models/beta_app_review_detail'
require 'spaceship/connect_api/testflight/models/beta_app_review_submission'
require 'spaceship/connect_api/testflight/models/beta_group'
require 'spaceship/connect_api/testflight/models/beta_tester'
require 'spaceship/connect_api/testflight/models/beta_tester_metric'
require 'spaceship/connect_api/testflight/models/build'
require 'spaceship/connect_api/testflight/models/build_delivery'
require 'spaceship/connect_api/testflight/models/build_beta_detail'
require 'spaceship/connect_api/testflight/models/pre_release_version'

module Spaceship
  module ConnectAPI
    module TestFlight
      def self.client
        return Spaceship::ConnectAPI::TestFlight::Base.client
      end
    end
  end
end
