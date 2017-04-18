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

    attr_mapping({
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


    def self.factory(attrs)
      # Parse the dates
      # rubocop:disable Style/RescueModifier
      attrs['uploadDate'] = (Time.parse(attrs['uploadDate']) rescue attrs['uploadDate'])
      # rubocop:enable Style/RescueModifier

      obj = self.new(attrs)
    end

    def self.find(app_id, build_id)
      attrs = client.get_build(app_id, build_id)
      self.new(attrs) if attrs
    end

    # All build trains, each with its builds
    # @example
    #   {
    #     "1.0" => [
    #       Build1,
    #       Build2
    #     ],
    #     "1.1" => [
    #       Build3
    #     ]
    #   }
    def self.all(app_id, platform: nil)
      build_trains = client.all_build_trains(app_id: app_id, platform: platform)
      result = {}
      build_trains.each do |train_version|
        builds = client.all_builds_for_train(app_id: app_id, platform: platform, train_version: train_version)
        result[train_version] = builds.collect do |current_build|
          self.factory(current_build) # TODO: when inspecting those builds, something's wrong, it doesn't expose the attributes. I don't know why
        end
      end
      return result
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
  end
end
