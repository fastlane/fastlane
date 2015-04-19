module Fastlane
  class ConfigurationHelper
    def self.parse(action, params)
      begin
        first_element = (action.available_options.first rescue nil) # might also be nil
        if first_element and first_element.kind_of?FastlaneCore::ConfigItem
          return FastlaneCore::Configuration.create(action.available_options, params)
        elsif first_element
          Helper.log.error "Action '#{action}' uses the old configuration format."
          raise "Old configuration format".red if Helper.is_test? # only fail in tests - this might be removed in the future, once all actions are migrated
          return params
        else
          # No parameters at all - that's okay
        end
      rescue => ex
        Helper.log.fatal "You provided an option to action #{action.action_name} which is not supported.".red
        Helper.log.fatal "Check out the available options below or run `fastlane action #{action.action_name}`".red
        raise ex
      end
    end
  end
end