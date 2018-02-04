module Fastlane
  class CrashlyticsBetaCommandLineHandler
    def self.info_from_options(options)
      beta_info = CrashlyticsBetaInfo.new
      beta_info.crashlytics_path = options.crashlytics_path
      beta_info.api_key = options.api_key
      beta_info.build_secret = options.build_secret
      beta_info.emails = options.emails
      beta_info.groups = options.groups
      beta_info.schemes = [options.scheme] if options.scheme
      beta_info.export_method = options.export_method

      beta_info
    end

    def self.apply_options(command)
      command.option('--crashlytics_path STRING', String, 'Path to Crashlytics.framework')
      command.option('--api_key STRING', String, 'Crashlytics API key')
      command.option('--build_secret STRING', String, 'Crashlytics build secret')
      command.option('--emails ARRAY', Array, 'List of emails to invite')
      command.option('--groups ARRAY', Array, 'List of group aliases to invite')
      command.option('--scheme STRING', String, 'Xcode scheme')
      command.option('--export_method STRING', String, 'Provisioning profile type (ad-hoc, enterprise, development)')
    end
  end
end
