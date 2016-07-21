module Fastlane
  class CrashlyticsBetaInfo
    attr_accessor :api_key
    attr_accessor :build_secret
    attr_accessor :emails
    attr_accessor :scheme
    attr_accessor :export_method

    def api_key_present?
      !api_key.nil?
    end

    def api_key_valid?
      api_key_present? && api_key.to_s.length == 40
    end

    def build_secret_present?
      !build_secret.nil?
    end

    def build_secret_valid?
      build_secret_present? && build_secret.to_s.length == 64
    end
  end
end
