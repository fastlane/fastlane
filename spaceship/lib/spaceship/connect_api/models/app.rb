require_relative './model'
require_relative './build'

module Spaceship
  module ConnectAPI
    class App
      include Spaceship::ConnectAPI::Model

      attr_accessor :name
      attr_accessor :bundle_id
      attr_accessor :sku
      attr_accessor :primary_locale
      attr_accessor :removed
      attr_accessor :is_aag

      self.attr_mapping({
        "name" => "name",
        "bundleId" => "bundle_id",
        "sku" => "sku",
        "primaryLocale" => "primary_locale",
        "removed" => "removed",
        "isAAG" => "is_aag"
      })

      def self.type
        return "apps"
      end

      #
      # Apps
      #

      def self.find(bundle_id)
        return client.page do
          client.get_apps(filter: { bundleId: bundle_id })
        end.map do |resp|
          Spaceship::ConnectAPI::App.parse(resp)
        end.flatten.find do |app|
          app.bundle_id == bundle_id
        end
      end

      #
      # Builds
      #

      def builds(filter: {}, includes: nil, limit: nil, sort: nil)
        filter ||= {}
        filter[:app] = id

        return client.page do
          client.get_builds(filter: filter, includes: includes, limit: limit, sort: sort)
        end.map do |resp|
          Spaceship::ConnectAPI::Build.parse(resp)
        end.flatten
      end
    end
  end
end
