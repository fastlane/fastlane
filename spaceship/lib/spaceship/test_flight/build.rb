require 'time'

require_relative 'base'
require_relative 'test_info'
require_relative 'export_compliance'
require_relative 'beta_review_info'
require_relative 'build_trains'

module Spaceship
  module TestFlight
    class Build < Base
      # @example
      #   "com.sample.app"
      attr_accessor :bundle_id

      # @example
      #   "testflight.build.state.testing.active"
      # @example
      #   "testflight.build.state.processing"
      attr_accessor :internal_state

      # @example
      #   "testflight.build.state.submit.ready"
      # @example
      #   "testflight.build.state.processing"
      attr_accessor :external_state

      # Internal build ID (int)
      # @example
      #   19285309
      attr_accessor :id

      # @example
      #   "1.0"
      attr_accessor :train_version

      # @example
      #   "152"
      attr_accessor :build_version

      attr_accessor :beta_review_info

      attr_accessor :export_compliance

      attr_accessor :test_info

      attr_accessor :install_count
      attr_accessor :invite_count
      attr_accessor :crash_count

      attr_accessor :did_notify

      attr_accessor :upload_date

      attr_accessor :dsym_url
      attr_accessor :build_sdk
      attr_accessor :include_symbols
      attr_accessor :number_of_asset_packs
      attr_accessor :contains_odr
      attr_accessor :file_name

      attr_mapping({
        'appAdamId' => :app_id,
        'providerId' => :provider_id,
        'bundleId' => :bundle_id,
        'trainVersion' => :train_version,
        'buildVersion' => :build_version,
        'betaReviewInfo' => :beta_review_info,
        'exportCompliance' => :export_compliance,
        'internalState' => :internal_state,
        'externalState' => :external_state,
        'testInfo' => :test_info,
        'installCount' => :install_count,
        'inviteCount' => :invite_count,
        'crashCount' => :crash_count,
        'didNotify' => :did_notify,
        'uploadDate' => :upload_date,
        'id' => :id,
        'dSYMUrl' => :dsym_url,
        'buildSdk' => :build_sdk,
        'includesSymbols' => :include_symbols,
        'numberOfAssetPacks' => :number_of_asset_packs,
        'containsODR' => :contains_odr,
        'fileName' => :file_name
      })

      BUILD_STATES = {
        processing: 'testflight.build.state.processing',
        active: 'testflight.build.state.testing.active',
        ready_to_submit: 'testflight.build.state.submit.ready',
        ready_to_test: 'testflight.build.state.testing.ready',
        export_compliance_missing: 'testflight.build.state.export.compliance.missing',
        review_rejected: 'testflight.build.state.review.rejected'
      }

      # Find a Build by `build_id`.
      #
      # @return (Spaceship::TestFlight::Build)
      def self.find(app_id: nil, build_id: nil)
        attrs = client.get_build(app_id: app_id, build_id: build_id)
        self.new(attrs)
      end

      def self.all(app_id: nil, platform: nil, retry_count: 0)
        trains = BuildTrains.all(app_id: app_id, platform: platform, retry_count: retry_count)
        trains.values.flatten
      end

      def self.builds_for_train(app_id: nil, platform: nil, train_version: nil, retry_count: 3)
        builds_data = client.get_builds_for_train(app_id: app_id, platform: platform, train_version: train_version, retry_count: retry_count)
        builds_data.map { |data| self.new(data) }
      end

      # Just the builds, as a flat array, that are still processing
      def self.all_processing_builds(app_id: nil, platform: nil, retry_count: 0)
        all(app_id: app_id, platform: platform, retry_count: retry_count).find_all(&:processing?)
      end

      def self.latest(app_id: nil, platform: nil)
        all(app_id: app_id, platform: platform).sort_by(&:upload_date).last
      end

      # reload the raw_data resource for this build.
      # This is useful when we start with a partial build response as returned by the BuildTrains,
      # but then need to look up some attributes on the full build representation.
      #
      # Note: this will overwrite any non-saved changes to the object
      #
      # @return (Spaceship::Base::DataHash) the raw_data of the build.
      def reload
        self.raw_data = self.class.find(app_id: app_id, build_id: id).raw_data
      end

      def ready_to_submit?
        external_state == BUILD_STATES[:ready_to_submit]
      end

      def ready_to_test?
        external_state == BUILD_STATES[:ready_to_test]
      end

      def active?
        external_state == BUILD_STATES[:active]
      end

      def processing?
        external_state == BUILD_STATES[:processing]
      end

      def export_compliance_missing?
        external_state == BUILD_STATES[:export_compliance_missing]
      end

      def review_rejected?
        external_state == BUILD_STATES[:review_rejected]
      end

      def processed?
        active? || ready_to_submit? || export_compliance_missing? || review_rejected?
      end

      # Getting builds from BuildTrains only gets a partial Build object
      # We are then requesting the full build from iTC when we need to access
      # any of the variables below, because they are not included in the partial Build objects
      #
      # `super` here calls `beta_review_info` as defined by the `attr_mapping` above.
      # @return (Spaceship::TestFlight::BetaReviewInfo)
      def beta_review_info
        super || reload
        BetaReviewInfo.new(super)
      end

      # @return (Spaceship::TestFlight::ExportCompliance)
      def export_compliance
        super || reload
        ExportCompliance.new(super)
      end

      # @return (Spaceship::TestFlight::TestInfo)
      def test_info
        super || reload
        TestInfo.new(super)
      end

      # @return (Time) an parsed Time value for the upload_date
      def upload_date
        Time.parse(super)
      end

      # saves the changes to the Build object to TestFlight
      def save!
        client.put_build(app_id: app_id, build_id: id, build: self)
      end

      def update_build_information!(description: nil, feedback_email: nil, whats_new: nil)
        test_info.description = description if description
        test_info.feedback_email = feedback_email if feedback_email
        test_info.whats_new = whats_new if whats_new
        save!
      end

      def submit_for_testflight_review!
        return if ready_to_test?
        client.post_for_testflight_review(app_id: app_id, build_id: id, build: self)
      end

      def expire!
        client.expire_build(app_id: app_id, build_id: id, build: self)
      end

      def add_group!(group)
        client.add_group_to_build(app_id: app_id, group_id: group.id, build_id: id)
      end
    end
  end
end
