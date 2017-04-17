module Testflight
  class Build < Base

    attr_accessor :bundle_id
    attr_accessor :build_version
    attr_accessor :beta_review_info
    attr_accessor :export_compliance

    attr_mapping({
      'bundleId' => :bundle_id,
      'buildVersion' => :build_version,
      'betaReviewInfo' => :beta_review_info,
      'exportCompliance' => :export_compliance
    })

    def self.find(provider_id, app_id, build_id)
      attrs = client.get_build(provider_id, app_id, build_id)
      self.new(attrs)
    end

    def beta_review_info
      BetaReviewInfo.new(super)
    end

    def export_compliance
      ExportCompliance.new(super)
    end
  end
end
