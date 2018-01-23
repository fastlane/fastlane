module Fastlane
  class ConfigurationHelper
    def self.parse(action, params)
      first_element = (action.available_options || []).first

      if first_element and first_element.kind_of?(FastlaneCore::ConfigItem)
        # default use case
        return FastlaneCore::Configuration.create(action.available_options, params)
      elsif first_element
        UI.error("Old configuration format for action '#{action}'") if Helper.is_test?
        return params
      else

        # No parameters... we still need the configuration object array
        FastlaneCore::Configuration.create(action.available_options, {})

      end
    rescue => ex
      if action.respond_to?(:action_name)
        UI.error("You passed invalid parameters to '#{action.action_name}'.")
        UI.error("Check out the error below and available options by running `fastlane action #{action.action_name}`")
      end
      raise ex
    end
  end
end
