module Fastlane
  class ConfigurationHelper
    def self.parse(action, params)
      begin
        if action.available_options.first.kind_of?FastlaneCore::ConfigItem
          return FastlaneCore::Configuration.create(action.available_options, params)
        else
          Helper.log.error "Action '#{action}' uses the old configuration format."
          raise "Old configuration format".red if Helper.is_test? # only fail in tests - this might be removed in the future, once all actions are migrated
          return params
        end
      rescue => ex
        Helper.log.fatal "You provided an option to action #{action.action_name} which is not supported.".red
        Helper.log.fatal "Check out the available options below or run `fastlane action #{action.action_name}`".red
        raise ex
      end
    end
  end
end