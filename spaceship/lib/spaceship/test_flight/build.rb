require 'time'

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

    attr_accessor :upload_date # TODO: can we auto-parse this? Just using `Time.new(...)` works for free

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
      'id' => :id
    })

    BUILD_STATES = {
      processing: 'testflight.build.state.processing',
      active: 'testflight.build.state.testing.active',
      ready: 'testflight.build.state.submit.ready',
      export_compliance_missing: 'testflight.build.state.export.compliance.missing'
    }

    def self.latest(app_id: nil, platform: nil)
      trains = BuildTrains.all(app_id: app_id, platform: platform)
      latest_build_data = trains.values.flatten.sort_by { |build| Time.parse(build['uploadDate']) }.last

      find(app_id, latest_build_data['id'])
    end

    def self.find(app_id, build_id)
      attrs = client.get_build(app_id, build_id)
      self.new(attrs) if attrs
    end

    def self.all_builds(app_id: nil, platform: nil)
      trains = BuildTrains.all(app_id: app_id, platform: platform)
      return trains.values.flatten.collect { |build| self.new(build) }
    end

    # Just the builds, as a flat array, that are still processing
    def self.all_processing_builds(app_id: nil, platform: nil)
      return self.all_builds(app_id: app_id, platform: platform).find_all(&:processing?)
    end

    def ready_to_submit?
      external_state == BUILD_STATES[:ready]
    end

    def processing?
      external_state == BUILD_STATES[:processing]
    end

    def beta_review_info
      BetaReviewInfo.new(super) # TODO: please document on what this `super` does, I didn't see it before in this context
    end

    def export_compliance
      ExportCompliance.new(super)
    end

    def test_info
      TestInfo.new(super)
    end

    def upload_date
      Time.parse(super)
    end

    def save!
      client.put_build(app_id, id, self)
    end

    # TODO: handle locales and multiple TestInfo properties
    def update_build_information!(description: nil, feedback_email: nil, whats_new: nil)
      test_info.description = description
      test_info.feedback_email = feedback_email
      test_info.whats_new = whats_new
      save!
    end

    def submit_for_review!
      client.post_for_review(app_id, id, self)
    end

    def add_group!(group)
      client.add_group_to_build(app_id, group.id, id)
    end
  end
end
