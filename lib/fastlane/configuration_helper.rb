module Fastlane
  class ConfigurationHelper
    def self.parse(action, params)
      first_element = (action.available_options || []).first

      if first_element and first_element.kind_of? FastlaneCore::ConfigItem
        # default use case
        return FastlaneCore::Configuration.create(action.available_options, params)

      elsif first_element
        puts "Old configuration format for action '#{action}'".red if Helper.is_test?
        return params
      else

        # No parameters... we still need the configuration object array
        FastlaneCore::Configuration.create(action.available_options, {})

      end
    rescue => ex
      if action.respond_to? :action_name
        Helper.log.fatal "You passed invalid parameters to '#{action.action_name}'.".red
        Helper.log.fatal "Check out the error below and available options by running `fastlane action #{action.action_name}`".red
      end
      raise ex
    end
  end
end
