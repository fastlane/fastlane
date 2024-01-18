require_relative '../model'
require_relative './build'

# rubocop:disable Metrics/ClassLength
module Spaceship
  class ConnectAPI
    class App
      include Spaceship::ConnectAPI::Model

      attr_accessor :name
      attr_accessor :bundle_id
      attr_accessor :sku
      attr_accessor :primary_locale
      attr_accessor :is_opted_in_to_distribute_ios_app_on_mac_app_store
      attr_accessor :removed
      attr_accessor :is_aag
      attr_accessor :content_rights_declaration
      attr_accessor :app_store_versions

      # Only available with Apple ID auth
      attr_accessor :distribution_type
      attr_accessor :educationDiscountType

      module ContentRightsDeclaration
        USES_THIRD_PARTY_CONTENT = "USES_THIRD_PARTY_CONTENT"
        DOES_NOT_USE_THIRD_PARTY_CONTENT = "DOES_NOT_USE_THIRD_PARTY_CONTENT"
      end

      module DistributionType
        APP_STORE = "APP_STORE"
        CUSTOM = "CUSTOM"
      end

      module EducationDiscountType
        DISCOUNTED = "DISCOUNTED"
        NOT_APPLICABLE = "NOT_APPLICABLE"
        NOT_DISCOUNTED = "NOT_DISCOUNTED"
      end

      self.attr_mapping({
        "name" => "name",
        "bundleId" => "bundle_id",
        "sku" => "sku",
        "primaryLocale" => "primary_locale",
        "isOptedInToDistributeIosAppOnMacAppStore" => "is_opted_in_to_distribute_ios_app_on_mac_app_store",
        "removed" => "removed",
        "isAAG" => "is_aag",
        "distributionType" => "distribution_type",
        "educationDiscountType" => "education_discount_type",

        "contentRightsDeclaration" => "content_rights_declaration",

        "appStoreVersions" => "app_store_versions",
      })

      ESSENTIAL_INCLUDES = [
        "appStoreVersions",
      ].join(",")

      def self.type
        return "apps"
      end

      #
      # Apps
      #

      def self.all(client: nil, filter: {}, includes: ESSENTIAL_INCLUDES, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_apps(filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      def self.find(bundle_id, client: nil)
        client ||= Spaceship::ConnectAPI
        return all(client: client, filter: { bundleId: bundle_id }).find do |app|
          app.bundle_id == bundle_id
        end
      end

      def self.create(client: nil, name: nil, version_string: nil, sku: nil, primary_locale: nil, bundle_id: nil, platforms: nil, company_name: nil)
        client ||= Spaceship::ConnectAPI
        client.post_app(
          name: name,
          version_string: version_string,
          sku: sku,
          primary_locale: primary_locale,
          bundle_id: bundle_id,
          platforms: platforms,
          company_name: company_name
        )
      end

      def self.get(client: nil, app_id: nil, includes: "appStoreVersions")
        client ||= Spaceship::ConnectAPI
        return client.get_app(app_id: app_id, includes: includes).first
      end

      # Updates app attributes, price tier and availability of an app in territories
      # Check Tunes patch_app method for explanation how to use territory_ids parameter with allow_removing_from_sale to remove app from sale
      def update(client: nil, attributes: nil, app_price_tier_id: nil, territory_ids: nil, allow_removing_from_sale: false)
        client ||= Spaceship::ConnectAPI
        attributes = reverse_attr_mapping(attributes)
        return client.patch_app(app_id: id, attributes: attributes, app_price_tier_id: app_price_tier_id, territory_ids: territory_ids, allow_removing_from_sale: allow_removing_from_sale)
      end

      #
      # App Info
      #

      def fetch_live_app_info(client: nil, includes: Spaceship::ConnectAPI::AppInfo::ESSENTIAL_INCLUDES)
        client ||= Spaceship::ConnectAPI
        states = [
          Spaceship::ConnectAPI::AppInfo::AppStoreState::READY_FOR_SALE,
          Spaceship::ConnectAPI::AppInfo::AppStoreState::PENDING_APPLE_RELEASE,
          Spaceship::ConnectAPI::AppInfo::AppStoreState::PENDING_DEVELOPER_RELEASE,
          Spaceship::ConnectAPI::AppInfo::AppStoreState::PROCESSING_FOR_APP_STORE,
          Spaceship::ConnectAPI::AppInfo::AppStoreState::IN_REVIEW,
          Spaceship::ConnectAPI::AppInfo::AppStoreState::DEVELOPER_REMOVED_FROM_SALE
        ]

        resp = client.get_app_infos(app_id: id, includes: includes)
        return resp.to_models.select do |model|
          states.include?(model.app_store_state)
        end.first
      end

      def fetch_edit_app_info(client: nil, includes: Spaceship::ConnectAPI::AppInfo::ESSENTIAL_INCLUDES)
        client ||= Spaceship::ConnectAPI
        states = [
          Spaceship::ConnectAPI::AppInfo::AppStoreState::PREPARE_FOR_SUBMISSION,
          Spaceship::ConnectAPI::AppInfo::AppStoreState::DEVELOPER_REJECTED,
          Spaceship::ConnectAPI::AppInfo::AppStoreState::REJECTED,
          Spaceship::ConnectAPI::AppInfo::AppStoreState::METADATA_REJECTED,
          Spaceship::ConnectAPI::AppInfo::AppStoreState::WAITING_FOR_REVIEW,
          Spaceship::ConnectAPI::AppInfo::AppStoreState::INVALID_BINARY
        ]

        resp = client.get_app_infos(app_id: id, includes: includes)
        return resp.to_models.select do |model|
          states.include?(model.app_store_state)
        end.first
      end

      def fetch_latest_app_info(client: nil, includes: Spaceship::ConnectAPI::AppInfo::ESSENTIAL_INCLUDES)
        client ||= Spaceship::ConnectAPI
        resp = client.get_app_infos(app_id: id, includes: includes)
        return resp.to_models.first
      end

      #
      # App Base Territory
      #

      def fetch_base_territory(client: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.get_app_base_territory(app_id: id)
        return resp.to_models.first
      end

      #
      # Available Territories
      #

      def fetch_available_territories(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        filter ||= {}
        resps = client.get_available_territories(app_id: id, filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      #
      # App Pricing
      #

      def fetch_app_prices(client: nil, filter: {}, includes: "priceTier", limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.get_app_prices(app_id: id, filter: filter, includes: includes, limit: limit, sort: sort)
        return resp.to_models
      end

      #
      # App Store Versions
      #

      def reject_version_if_possible!(client: nil, platform: nil)
        client ||= Spaceship::ConnectAPI
        platform ||= Spaceship::ConnectAPI::Platform::IOS
        filter = {
          appStoreState: [
            Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::PENDING_APPLE_RELEASE,
            Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::PENDING_DEVELOPER_RELEASE,
            Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::IN_REVIEW,
            Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::WAITING_FOR_REVIEW
          ].join(","),
          platform: platform
        }

        # Get the latest version
        version = get_app_store_versions(client: client, filter: filter, includes: "appStoreVersionSubmission")
                  .sort_by { |v| Gem::Version.new(v.version_string) }
                  .last

        return false if version.nil?
        return version.reject!
      end

      # Will make sure the current edit_version matches the given version number
      # This will either create a new version or change the version number
      # from an existing version
      # @return (Bool) Was something changed?
      def ensure_version!(version_string, platform: nil, client: nil)
        client ||= Spaceship::ConnectAPI
        app_store_version = get_edit_app_store_version(client: client, platform: platform)

        if app_store_version
          if version_string != app_store_version.version_string
            attributes = { versionString: version_string }
            app_store_version.update(client: client, attributes: attributes)
            return true
          end
          return false
        else
          attributes = { versionString: version_string, platform: platform }
          client.post_app_store_version(app_id: id, attributes: attributes)

          return true
        end
      end

      def get_latest_app_store_version(client: nil, platform: nil, includes: nil)
        client ||= Spaceship::ConnectAPI
        platform ||= Spaceship::ConnectAPI::Platform::IOS
        filter = {
          platform: platform
        }

        # Get the latest version
        return get_app_store_versions(client: client, filter: filter, includes: includes)
               .sort_by { |v| Date.parse(v.created_date) }
               .last
      end

      def get_live_app_store_version(client: nil, platform: nil, includes: Spaceship::ConnectAPI::AppStoreVersion::ESSENTIAL_INCLUDES)
        client ||= Spaceship::ConnectAPI
        platform ||= Spaceship::ConnectAPI::Platform::IOS
        filter = {
          appStoreState: [
            Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::READY_FOR_SALE,
            Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::DEVELOPER_REMOVED_FROM_SALE
          ].join(","),
          platform: platform
        }
        return get_app_store_versions(client: client, filter: filter, includes: includes).first
      end

      def get_edit_app_store_version(client: nil, platform: nil, includes: Spaceship::ConnectAPI::AppStoreVersion::ESSENTIAL_INCLUDES)
        client ||= Spaceship::ConnectAPI
        platform ||= Spaceship::ConnectAPI::Platform::IOS
        filter = {
          appStoreState: [
            Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::PREPARE_FOR_SUBMISSION,
            Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::DEVELOPER_REJECTED,
            Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::REJECTED,
            Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::METADATA_REJECTED,
            Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::WAITING_FOR_REVIEW,
            Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::INVALID_BINARY
          ].join(","),
          platform: platform
        }

        # Get the latest version
        return get_app_store_versions(client: client, filter: filter, includes: includes)
               .sort_by { |v| Gem::Version.new(v.version_string) }
               .last
      end

      def get_in_review_app_store_version(client: nil, platform: nil, includes: Spaceship::ConnectAPI::AppStoreVersion::ESSENTIAL_INCLUDES)
        client ||= Spaceship::ConnectAPI
        platform ||= Spaceship::ConnectAPI::Platform::IOS
        filter = {
          appStoreState: Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::IN_REVIEW,
          platform: platform
        }
        return get_app_store_versions(client: client, filter: filter, includes: includes).first
      end

      def get_pending_release_app_store_version(client: nil, platform: nil, includes: Spaceship::ConnectAPI::AppStoreVersion::ESSENTIAL_INCLUDES)
        client ||= Spaceship::ConnectAPI
        platform ||= Spaceship::ConnectAPI::Platform::IOS
        filter = {
          appStoreState: [
            Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::PENDING_APPLE_RELEASE,
            Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::PENDING_DEVELOPER_RELEASE
          ].join(','),
          platform: platform
        }
        return get_app_store_versions(client: client, filter: filter, includes: includes).first
      end

      def get_app_store_versions(client: nil, filter: {}, includes: Spaceship::ConnectAPI::AppStoreVersion::ESSENTIAL_INCLUDES, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        if limit.nil?
          resps = client.get_app_store_versions(app_id: id, filter: filter, includes: includes, limit: limit, sort: sort).all_pages
          return resps.flat_map(&:to_models)
        else
          resp = client.get_app_store_versions(app_id: id, filter: filter, includes: includes, limit: limit, sort: sort)
          return resp.to_models
        end
      end

      #
      # B2B
      #

      def disable_b2b
        update(attributes: {
          distributionType: DistributionType::APP_STORE,
          education_discount_type: EducationDiscountType::NOT_DISCOUNTED
        })
      end

      def enable_b2b
        update(attributes: {
          distributionType: App::DistributionType::CUSTOM,
          education_discount_type: EducationDiscountType::NOT_APPLICABLE
        })
      end

      #
      # Beta Feedback
      #

      def get_beta_feedback(client: nil, filter: {}, includes: "tester,build,screenshots", limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        filter ||= {}
        filter["build.app"] = id

        resps = client.get_beta_feedback(filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      #
      # Beta Testers
      #

      def get_beta_testers(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        filter ||= {}
        filter[:apps] = id

        resps = client.get_beta_testers(filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      #
      # Builds
      #

      def get_builds(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        filter ||= {}
        filter[:app] = id

        resps = client.get_builds(filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      def get_build_deliveries(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        filter ||= {}

        resps = client.get_build_deliveries(app_id: id, filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      def get_beta_app_localizations(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        filter ||= {}
        filter[:app] = id

        resps = client.get_beta_app_localizations(filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      def get_beta_groups(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        filter ||= {}
        filter[:app] = id

        resps = client.get_beta_groups(filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      def create_beta_group(client: nil, group_name: nil, is_internal_group: false, public_link_enabled: false, public_link_limit: 10_000, public_link_limit_enabled: false)
        client ||= Spaceship::ConnectAPI
        resps = client.create_beta_group(
          app_id: id,
          group_name: group_name,
          is_internal_group: is_internal_group,
          public_link_enabled: public_link_enabled,
          public_link_limit: public_link_limit,
          public_link_limit_enabled: public_link_limit_enabled
        ).all_pages
        return resps.flat_map(&:to_models).first
      end

      #
      # Education
      #

      def disable_educational_discount
        update(attributes: {
          education_discount_type: EducationDiscountType::NOT_DISCOUNTED
        })
      end

      def enable_educational_discount
        update(attributes: {
          education_discount_type: EducationDiscountType::DISCOUNTED
        })
      end

      #
      # Review Submissions
      #

      def get_ready_review_submission(client: nil, platform:, includes: nil)
        client ||= Spaceship::ConnectAPI
        filter = {
          state: [
            Spaceship::ConnectAPI::ReviewSubmission::ReviewSubmissionState::READY_FOR_REVIEW
          ].join(","),
          platform: platform
        }

        return get_review_submissions(client: client, filter: filter, includes: includes).first
      end

      def get_in_progress_review_submission(client: nil, platform:, includes: nil)
        client ||= Spaceship::ConnectAPI
        filter = {
          state: [
            Spaceship::ConnectAPI::ReviewSubmission::ReviewSubmissionState::WAITING_FOR_REVIEW,
            Spaceship::ConnectAPI::ReviewSubmission::ReviewSubmissionState::IN_REVIEW,
            Spaceship::ConnectAPI::ReviewSubmission::ReviewSubmissionState::UNRESOLVED_ISSUES
          ].join(","),
          platform: platform
        }

        return get_review_submissions(client: client, filter: filter, includes: includes).first
      end

      # appStoreVersionForReview,items
      def get_review_submissions(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_review_submissions(app_id: id, filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      def create_review_submission(client: nil, platform:)
        client ||= Spaceship::ConnectAPI
        resp = client.post_review_submission(app_id: id, platform: platform)
        return resp.to_models.first
      end

      #
      # Users
      #

      def add_users(client: nil, user_ids: nil)
        client ||= Spaceship::ConnectAPI
        user_ids.each do |user_id|
          client.add_user_visible_apps(user_id: user_id, app_ids: [id])
        end
      end

      def remove_users(client: nil, user_ids: nil)
        client ||= Spaceship::ConnectAPI
        user_ids.each do |user_id|
          client.delete_user_visible_apps(user_id: user_id, app_ids: [id])
        end
      end

      #
      # In-App Purchases
      #

      def get_in_app_purchase(client: nil, purchase_id:, includes: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_in_app_purchase(purchase_id: purchase_id, includes: includes)
        return resps.to_models.first
      end

      def get_in_app_purchases(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_in_app_purchases(app_id: id, filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      def create_in_app_purchase(client: nil, name:, product_id:, in_app_purchase_type:, review_note: nil, family_sharable: nil, available_in_all_territories: nil, mighty_logger: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.create_in_app_purchase(app_id: id, name: name, product_id: product_id, in_app_purchase_type: in_app_purchase_type, review_note: review_note, family_sharable: family_sharable, available_in_all_territories: available_in_all_territories, mighty_logger: mighty_logger)
        return resps.to_models.first
      end

      #
      # Subscription Groups
      #

      def get_subscription_group(client: nil, family_id:, includes: Spaceship::ConnectAPI::SubscriptionGroup::ESSENTIAL_INCLUDES)
        client ||= Spaceship::ConnectAPI
        resps = client.get_subscription_group(family_id: family_id, includes: includes).all_pages
        return resps.flat_map(&:to_models).first
      end

      def get_subscription_groups(client: nil, filter: {}, includes: Spaceship::ConnectAPI::SubscriptionGroup::ESSENTIAL_INCLUDES, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_subscription_groups(app_id: id, filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      def create_subscription_group(client: nil, reference_name:)
        client ||= Spaceship::ConnectAPI
        resps = client.create_subscription_group(reference_name: reference_name, app_id: id)
        return resps.to_models.first
      end

      #
      # Subscriptions
      #

      def get_subscription(client: nil, purchase_id:, includes: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_subscription(purchase_id: purchase_id, includes: includes)
        return resps.to_models.first
      end

      def create_subscription(client: nil, family_id:, name:, product_id:, available_in_all_territories: nil, family_sharable: nil, review_note: nil, subscription_period: nil, group_level: nil, mighty_logger: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.create_subscription(family_id: family_id, name: name, product_id: product_id, available_in_all_territories: available_in_all_territories, family_sharable: family_sharable, review_note: review_note, subscription_period: subscription_period, group_level: group_level, mighty_logger: mighty_logger)
        return resps.to_models.first
      end

    end
  end
end
# rubocop:enable Metrics/ClassLength
