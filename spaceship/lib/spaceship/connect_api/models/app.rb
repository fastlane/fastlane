require_relative '../model'
require_relative './build'

module Spaceship
  class ConnectAPI
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

      def self.all(filter: {}, includes: nil, limit: nil, sort: nil)
        resps = Spaceship::ConnectAPI.get_apps(filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      def self.find(bundle_id)
        return all(filter: { bundleId: bundle_id }).find do |app|
          app.bundle_id == bundle_id
        end
      end

      def self.get(app_id: nil, includes: nil)
        return Spaceship::ConnectAPI.get_app(app_id: app_id, includes: includes).first
      end

      #
      # Beta Feedback

      def get_beta_feedback(filter: {}, includes: "tester,build,screenshots", limit: nil, sort: nil)
        filter ||= {}
        filter["build.app"] = id

        resps = Spaceship::ConnectAPI.get_beta_feedback(filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      #
      # Beta Testers
      #

      def get_beta_testers(filter: {}, includes: nil, limit: nil, sort: nil)
        filter ||= {}
        filter[:apps] = id

        resps = Spaceship::ConnectAPI.get_beta_testers(filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      #
      # Builds
      #

      def get_builds(filter: {}, includes: nil, limit: nil, sort: nil)
        filter ||= {}
        filter[:app] = id

        resps = Spaceship::ConnectAPI.get_builds(filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      def get_build_deliveries(filter: {}, includes: nil, limit: nil, sort: nil)
        filter ||= {}
        filter[:app] = id

        resps = Spaceship::ConnectAPI.get_build_deliveries(filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      def get_beta_app_localizations(filter: {}, includes: nil, limit: nil, sort: nil)
        filter ||= {}
        filter[:app] = id

        resps = Spaceship::ConnectAPI.get_beta_app_localizations(filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      def get_beta_groups(filter: {}, includes: nil, limit: nil, sort: nil)
        filter ||= {}
        filter[:app] = id

        resps = Spaceship::ConnectAPI.get_beta_groups(filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end
    end
  end
end
