module Fastlane
  class ConfigurationHelper
    def self.parse(action, params)
      begin
        options = FastlaneCore::Configuration.create(action.available_options, params)
      rescue => ex
        Helper.log.fatal "You provided option an option to action #{action.action_name} which is not supported.".red
        Helper.log.fatal "Check out the available options below or run `fastlane action #{action.action_name}`".red
        raise ex
      end
    end
  end
end