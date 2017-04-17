module Testflight
  class TestInfo < Base

    attr_accessor :locale, :primary_locale, :description, :feedback_email
    attr_accessor :marketing_url, :privacy_policy_url, :privacy_policy, :whats_new

    attr_mapping({
      'whatsNew' => :whats_new
    })

    def whats_new
      raw_data.first['whatsNew']
    end

    def whats_new=(value)
      raw_data.first['whatsNew'] = value
    end

  end
end