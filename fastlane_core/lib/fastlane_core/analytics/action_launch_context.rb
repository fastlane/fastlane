require_relative '../helper'
require_relative 'app_identifier_guesser'

module FastlaneCore
  class ActionLaunchContext
    UNKNOWN_P_HASH = 'unknown'

    attr_accessor :action_name
    attr_accessor :p_hash
    attr_accessor :platform
    attr_accessor :fastlane_client_language # example: ruby fastfile, swift fastfile

    def initialize(action_name: nil, p_hash: UNKNOWN_P_HASH, platform: nil, fastlane_client_language: nil)
      @action_name = action_name
      @p_hash = p_hash
      @platform = platform
      @fastlane_client_language = fastlane_client_language
    end

    def self.context_for_action_name(action_name, fastlane_client_language: :ruby, args: nil)
      app_id_guesser = FastlaneCore::AppIdentifierGuesser.new(args: args)
      return self.new(
        action_name: action_name,
        p_hash: app_id_guesser.p_hash || UNKNOWN_P_HASH,
        platform: app_id_guesser.platform,
        fastlane_client_language: fastlane_client_language
      )
    end

    def build_tool_version
      if platform == :android
        return 'android'
      else
        return "Xcode #{Helper.xcode_version}"
      end
    end
  end
end
