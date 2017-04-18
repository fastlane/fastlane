module Testflight
  class Build < Base
    attr_accessor :bundle_id, :internal_state, :external_state
    attr_accessor :build_version
    attr_accessor :beta_review_info
    attr_accessor :export_compliance
    attr_accessor :test_info

    attr_mapping({
      'bundleId' => :bundle_id,
      'buildVersion' => :build_version,
      'betaReviewInfo' => :beta_review_info,
      'exportCompliance' => :export_compliance,
      'internalState' => :internal_state,
      'externalState' => :external_state,
      'testInfo' => :test_info
    })

    def self.find(provider_id, app_id, build_id)
      attrs = client.get_build(provider_id, app_id, build_id)
      self.new(attrs) if attrs
    end

    def beta_review_info
      BetaReviewInfo.new(super)
    end

    def export_compliance
      ExportCompliance.new(super)
    end

    def test_info
      TestInfo.new(super)
    end
  end
end
