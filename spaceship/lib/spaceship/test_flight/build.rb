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
      'didNotify' => :did_notify
    })

    def self.find(provider_id, app_id, build_id)
      attrs = client.get_build(provider_id, app_id, build_id)
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
    def self.all(provider_id, app_id, platform: nil)
      build_trains = client.all_build_trains(provider_id: provider_id, app_id: app_id, platform: platform)
      result = {}
      build_trains.each do |train_version|
        builds = client.all_builds_for_train(provider_id: provider_id, app_id: app_id, platform: platform, train_version: train_version)
        result[train_version] = builds.collect do |current_build|
          self.factory(current_build) # TODO: when inspecting those builds, something's wrong, it doesn't expose the attributes. I don't know why
        end
      end
      return result
    end
    
    # Just the builds, as a flat array, that are still processing
    def self.all_processing_builds(provider_id, app_id, platform: nil)
      all_builds = self.all(provider_id, app_id, platform: platform)
      result = []
      all_builds.each do |train_version, builds|
        result += builds.find_all do |build|
          build.external_state == "testflight.build.state.processing"
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
