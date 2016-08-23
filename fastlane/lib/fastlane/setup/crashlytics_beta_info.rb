module Fastlane
  class CrashlyticsBetaInfo
    EXPORT_METHODS = %w(app-store ad-hoc package enterprise development developer-id).freeze

    attr_accessor :crashlytics_path
    attr_accessor :api_key
    attr_accessor :build_secret
    attr_accessor :emails
    attr_accessor :groups
    attr_accessor :schemes
    attr_accessor :export_method

    def schemes=(schemes)
      @schemes = schemes ? schemes.compact : nil
    end

    def emails=(emails)
      @emails = emails ? emails.compact : nil
    end

    def groups=(groups)
      @groups = groups ? groups.compact : nil
    end

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
      !emails.nil? && emails.any? { |email| !email.empty? }
    end

    def groups_valid?
      !groups.nil? && groups.any? { |groups| !groups.empty? }
    end

    def schemes_valid?
      !schemes.nil? && schemes.size == 1 && !schemes.first.empty?
    end

    def export_method_valid?
      !export_method.nil? && !export_method.empty? && EXPORT_METHODS.include?(export_method)
    end

    def has_all_detectable_values?
      api_key && build_secret && crashlytics_path && emails && schemes
    end
  end
end
