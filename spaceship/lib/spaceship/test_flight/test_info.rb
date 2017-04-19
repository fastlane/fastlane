module TestFlight
  class TestInfo < Base
    attr_accessor :locale, :primary_locale, :description, :feedback_email
    attr_accessor :marketing_url, :privacy_policy_url, :privacy_policy, :whats_new

    attr_mapping({
      'whatsNew' => :whats_new
    })

    # TODO: handle multiple testInfo's for each locale

    def description
      raw_data.first['description']
    end

    def description=(value)
      raw_data.first['description'] = value
    end

    def feedback_email
      raw_data.first['feedback_email']
    end

    def feedback_email=(value)
      raw_data.first['feedback_email'] = value
    end

    def whats_new
      raw_data.first['whatsNew']
    end

    def whats_new=(value)
      raw_data.first['whatsNew'] = value
    end
  end
end
