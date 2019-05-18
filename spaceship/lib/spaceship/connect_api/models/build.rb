require_relative './model'
require 'spaceship/test_flight/build'
module Spaceship
  module ConnectAPI
    class Build
      include Spaceship::ConnectAPI::Model

      attr_accessor :version
      attr_accessor :uploaded_date
      attr_accessor :expiration_date
      attr_accessor :expired
      attr_accessor :min_os_version
      attr_accessor :icon_asset_token
      attr_accessor :processing_state
      attr_accessor :uses_non_exempt_encryption
      attr_accessor :qc_state

      attr_accessor :app
      attr_accessor :beta_app_review_submission
      attr_accessor :build_beta_detail
      attr_accessor :pre_release_version

      attr_mapping({
        "version" => "version",
        "uploadedDate" => "uploaded_date",
        "expirationDate" => "expiration_date",
        "expired" => "expired",
        "minOsVersion" => "min_os_version",
        "iconAssetToken" => "icon_asset_token",
        "processingState" => "processing_state",
        "usesNonExemptEncryption" => "uses_non_exempt_encryption",
        "qcState" => "qc_state", # Undocumented in API docs as of 2019-05-18

        "app" => "app",
        "betaAppReviewSubmission" => "beta_app_review_submission",
        "buildBetaDetail" => "build_beta_detail",
        "preReleaseVersion" => "pre_release_version"
      })

      module ProcessingState
        PROCESSING = "PROCESSING"
        FAILED = "FAILED"
        INVALID = "INVALID"
        VALID = "VALID"
      end

      # Undocumented in API docs as of 2019-05-18
      # They have been populated based on API response observation
      module QCState
        BETA_INTERNAL_TESTING = "BETA_INTERNAL_TESTING"
        BETA_WAITING = "BETA_WAITING"
        BETA_APPROVED = "BETA_APPROVED"
        BETA_REJECT_COMPLETE = "BETA_REJECT_COMPLETE"
      end

      def self.type
        return "builds"
      end

      #
      # Helpers
      #

      def app_version
        raise "No pre_release_version included" unless pre_release_version
        return pre_release_version.version
      end

      def app_id
        raise "No app included" unless app
        return app.id
      end

      def bundle_id
        raise "No app included" unless app
        return app.bundle_id
      end

      def processed?
        return processing_state == ProcessingState::VALID
      end

      def ready_for_beta_submission?
        return [QCState::BETA_INTERNAL_TESTING, QCState::BETA_REJECT_COMPLETE].include?(qc_state)
      end

      # This is here temporarily until the removal of Spaceship::TestFlight
      def to_testflight_build
        h = {
          'buildVersion' => version,
          'uploadDate' => uploaded_date,
          'externalState' => processed? ? Spaceship::TestFlight::Build::BUILD_STATES[:active] : Spaceship::TestFlight::Build::BUILD_STATES[:processing],
          'appAdamId' => app_id,
          'bundleId' => bundle_id,
          'trainVersion' => app_version
        }

        return Spaceship::TestFlight::Build.new(h)
      end

      #
      # API
      #

      def self.all(app_id: nil, version: nil, build_number: nil, includes: "app,buildBetaDetail,preReleaseVersion", sort: "-uploadedDate", limit: 30)
        resps = client.get_builds(
          filter: { app: app_id, "preReleaseVersion.version" => version, version: build_number },
          includes: includes,
          sort: sort,
          limit: limit
        ).all_pages
        return resps.map(&:to_models).flatten
      end

      def add_beta_groups(beta_groups: nil)
        beta_groups ||= []
        beta_group_ids = beta_groups.map(&:id)
        return client.add_beta_groups_to_build(build_id: id, beta_group_ids: beta_group_ids)
      end

      def beta_build_localizations(filter: {}, includes: nil, limit: nil, sort: nil)
        resps = client.get_beta_build_localizations(
          filter: { build: id },
          includes: includes,
          sort: sort,
          limit: limit
        ).all_pages
        return resps.map(&:to_models).flatten
      end

      def build_beta_details(filter: {}, includes: nil, limit: nil, sort: nil)
        resps = client.get_build_beta_details(
          filter: { build: id },
          includes: includes,
          sort: sort,
          limit: limit
        ).all_pages
        return resps.map(&:to_models).flatten
      end

      def post_beta_app_review_submission
        return client.post_beta_app_review_submissions(build_id: id)
      end
    end
  end
end
