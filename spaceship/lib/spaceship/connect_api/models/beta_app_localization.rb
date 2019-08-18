require_relative '../model'
module Spaceship
  class ConnectAPI
    class BetaAppLocalization
      include Spaceship::ConnectAPI::Model

      attr_accessor :feedback_email
      attr_accessor :marketing_url
      attr_accessor :privacy_policy_url
      attr_accessor :tv_os_privacy_policy
      attr_accessor :description
      attr_accessor :locale

      attr_mapping({
        "feedbackEmail" => "feedback_email",
        "marketingUrl" => "marketing_url",
        "privacyPolicyUrl" => "privacy_policy_url",
        "tvOsPrivacyPolicy" => "tv_os_privacy_policy",
        "description" => "description",
        "locale" => "locale"
      })

      def self.type
        return "betaAppLocalizations"
      end
    end
  end
end
