module Fastlane
  class ConfigurationHelper
    def self.parse(action, params)
      begin
        first_element = (action.available_options.first rescue nil) # might also be nil
        
        if first_element and first_element.kind_of?FastlaneCore::ConfigItem
          # default use case
          return FastlaneCore::Configuration.create(action.available_options, params)

        elsif first_element
          Helper.log.error "Action '#{action}' uses the old configuration format."
          puts "Old configuration format for action '#{action}'".red if Helper.is_test?
          return params
        else

          # No parameters... we still need the configuration object array
          FastlaneCore::Configuration.create(action.available_options, {})

        end
      rescue => ex
        Helper.log.fatal "You invalid parameters to '#{action.action_name}'.".red
        Helper.log.fatal "Check out the error below and available options by running `fastlane action #{action.action_name}`".red
        raise ex
      end
    end
  end
end