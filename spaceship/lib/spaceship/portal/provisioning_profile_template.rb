require_relative 'portal_base'

module Spaceship
  module Portal
    class ProvisioningProfileTemplate < PortalBase
      ##
      # Data model representing a provisioning profile template

      # @return (String) Template's description
      # @example
      #   "Subscription Service iOS (dist)"
      attr_accessor :template_description

      # @return (String) Template's purpose description
      # @example
      #   "Generic Provisioning Profile Template for App: com.apple.smoot.subscriptionservice"
      attr_accessor :purpose_description

      # @return (String) Template's purpose name displayed in Dev Portal
      # @example
      #   "Subscription Service iOS (dist)"
      attr_accessor :purpose_display_name

      # @return (String) Template's purpose name
      # @example
      #   "Subscription Service iOS (dist)"
      attr_accessor :purpose_name

      # @return (String) Template version
      # @example
      #   "1"
      attr_accessor :version

      # @return (Array) A list of extended entitlement IDs defined by the template
      #   This is almost always nil :shrug_emoticon:
      # @example
      #   nil
      # @example
      #   ["com.apple.smoot.subscriptionservice"]
      attr_accessor :entitlements

      attr_mapping({
        'description' => :template_description,
        'purposeDescription' => :purpose_description,
        'purposeDisplayName' => :purpose_display_name,
        'purposeName' => :purpose_name,
        'version' => :version,
        'entitlements' => :entitlements
      })
    end
  end
end
