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

    def self.latest(provider_id: nil, app_id: nil, build_id: nil)
      trains = BuildTrains.all(provider_id: provider_id, app_id: app_id, platform: platform)
      latest_build_data = trains.values.flatten.sort_by { |build| build.upload_date }.last

      find(provider_id, app_id, latest_build_data['id'])
    end

    def self.find(provider_id, app_id, build_id)
      attrs = client.get_build(provider_id, app_id, build_id)
      self.new(attrs) if attrs
    end

    # Just the builds, as a flat array, that are still processing
    def self.all_processing_builds(provider_id: nil, app_id: nil, platform: nil)
      trains = BuildTrains.all(provider_id: provider_id, app_id: app_id, platform: platform)
      all_builds = trains.values.flatten
      all_builds.find_all do |build|
        build.external_state == "testflight.build.state.processing"
      end
    end

    # @param train_version and build_version are used internally
    def self.wait_for_build_processing_to_be_complete(provider_id, app_id, train_version: nil, build_version: nil, platform: nil)
      # TODO: do we want to move this somewhere else?
      processing = all_processing_builds(provider_id, app_id, platform: platform)
      return if processing.count == 0

      if train_version && build_version
        # We already have a specific build we wait for, use that one
        build = processing.find { |b| b.train_version == train_version && b.build_version == build_version }
        return if build.nil? # wohooo, the build doesn't show up in the `processing` list any more, we're good
      else
        # Fetch the most recent build, as we want to wait for that one
        # any previous builds might be there since they're stuck
        build = processing.sort_by { |b| Time.new(b.upload_date) }.last # TODO: Remove the `Time.new` once we can auto-parse it (see attr_accessor for upload_date)
      end

      # We got the build we want to wait for, wait now...
      sleep(10)
      # TODO: we really should move this somewhere else, so that we can print out what we used to print
      # UI.message("Waiting for iTunes Connect to finish processing the new build (#{build.train_version} - #{build.build_version})")
      # we don't have access to FastlaneCore::UI in spaceship
      wait_for_build_processing_to_be_complete(provider_id, app_id,
                                               build_version: build.build_version,
                                               train_version: build.train_version,
                                               platform: platform)

      # Also when it's finished we used to do
      # UI.success("Successfully finished processing the build")
      # UI.message("You can now tweet: ")
      # UI.important("iTunes Connect #iosprocessingtime #{minutes} minutes")
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
      client.put_build(provider_id, app_id, id, self)
    end

    #TODO: handle locales and multiple TestInfo properties
    def update_build_information!(description: nil, feedback_email: nil, whats_new: nil)
      test_info.description = description
      test_info.feedback_email = feedback_email
      test_info.whats_new = whats_new
      save!
    end

    def submit_for_review!
      client.post_for_review(provider_id, app_id, id, self)
    end

    def add_group!(group)
      client.add_group_to_build(provider_id, app_id, group.id, id)
    end
  end
end
