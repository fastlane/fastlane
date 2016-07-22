module Fastlane
  class CrashlyticsBetaInfo
    attr_accessor :crashlytics_path
    attr_accessor :api_key
    attr_accessor :build_secret
    attr_accessor :emails
    attr_accessor :scheme
    attr_accessor :export_method

    def api_key_valid?
      !api_key.nil? && api_key.to_s.length == 40
    end

    def build_secret_valid?
      !build_secret.nil? && build_secret.to_s.length == 64
    end

    def crashlytics_path_valid?
      !crashlytics_path.nil? && File.exist?(crashlytics_path) && File.exist?(File.join(crashlytics_path, 'submit'))
    end
  end
end
