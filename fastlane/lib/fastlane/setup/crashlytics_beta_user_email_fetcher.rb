module Fastlane
  class CrashlyticsBetaUserEmailFetcher
    def initialize(app_file_path = nil)
      @app_file_config = CredentialsManager::AppfileConfig.new(app_file_path)
    end

    def fetch
      @app_file_config.data[:itunes_connect_id] ||
        @app_file_config.data[:apple_dev_portal_id] ||
        @app_file_config.data[:apple_id]
    end
  end
end
