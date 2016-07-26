module Fastlane
  class CrashlyticsBetaInfo
    attr_accessor :crashlytics_path
    attr_accessor :api_key
    attr_accessor :build_secret
    attr_accessor :emails
    attr_accessor :schemes
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

    def emails_valid?
      !emails.nil? && emails.any? { |email| !email.nil? && !email.empty? }
    end

    def schemes_valid?
      !schemes.nil? && schemes.size == 1 && !schemes.first.empty?
    end

    def export_method_valid?
      !export_method.nil? && !export_method.empty? # TODO: && is one of a few valid values
    end

    def complete?
      api_key && build_secret && crashlytics_path && emails && schemes # && export_method
    end

    def schemes=(schemes)
      return if schemes.nil?
      @schemes = schemes.compact
    end
  end
end
