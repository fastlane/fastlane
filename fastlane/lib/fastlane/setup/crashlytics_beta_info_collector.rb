module Fastlane
  class CrashlyticsBetaInfoCollector
    def initialize(project_parser, user_email_fetcher, ui)
      @project_parser = project_parser
      @user_email_fetcher = user_email_fetcher
      @ui = ui

      @shown_fabric_org_help = false
    end

    # @param info CrashlyticsBetaInfo to supplement with needed info that is collected
    def collect_info_into(info)
      if user_provided_invalid_values?(info) || !info.has_all_detectable_values?
        @ui.message("\nTrying to discover Beta by Crashlytics info from your project...".cyan)
        parse_project_info_into(info)
        fetch_email_into(info)
      end

      prompt_for_missing_values(info)
    end

    def user_provided_invalid_values?(info)
      invalid = false

      if info.crashlytics_path && !info.crashlytics_path_valid?
        @ui.message("The crashlytics_path you provided (#{info.crashlytics_path}) is not valid.")
        invalid = true
      end

      if info.api_key && !info.api_key_valid?
        @ui.message("The api_key you provided (#{info.api_key}) is not valid.")
        invalid = true
      end

      if info.build_secret && !info.build_secret_valid?
        @ui.message("The build_secret you provided (#{info.build_secret}) is not valid.")
        invalid = true
      end

      if info.emails && !info.emails_valid?
        @ui.message("The email you provided (#{info.emails.first}) is not valid.")
        invalid = true
      end

      if info.schemes && !info.schemes_valid?
        @ui.message("The scheme you provided (#{info.schemes.first}) is not valid.")
        invalid = true
      end

      invalid
    end

    def parse_project_info_into(info)
      begin
        info_hash = @project_parser.parse
      rescue => ex
        @ui.important(ex.message)
      end

      if info_hash
        info.api_key = info_hash[:api_key] unless info.api_key_valid?
        info.build_secret = info_hash[:build_secret] unless info.build_secret_valid?
        info.crashlytics_path = info_hash[:crashlytics_path] unless info.crashlytics_path_valid?
        info.schemes = info_hash[:schemes] unless info.schemes_valid?
      end
    end

    def fetch_email_into(info)
      email = @user_email_fetcher.fetch
      info.emails = [email] if !info.emails_valid? && email
    end

    def prompt_for_missing_values(info)
      if !info.crashlytics_path || !info.crashlytics_path_valid?
        @ui.important("A Crashlytics submit binary path couldn't be discovered from your project 🔍")
        prompt_for_crashlytics_path(info)
      end

      if !info.api_key || !info.api_key_valid?
        @ui.important("Your Fabric organization's API Key couldn't be discovered from your project 🔍")
        show_fabric_org_help unless @shown_fabric_org_help
        prompt_for_api_key(info)
      end

      if !info.build_secret || !info.build_secret_valid?
        @ui.important("Your Fabric organization's Build Secret couldn't be discovered from your project 🔍")
        show_fabric_org_help unless @shown_fabric_org_help
        prompt_for_build_secret(info)
      end

      if (!info.emails || !info.emails_valid?) && !info.groups
        @ui.important("Your email address couldn't be discovered from your project 🔍")
        prompt_for_email(info)
      end

      if !info.schemes || info.schemes.empty?
        @ui.important("Your scheme couldn't be discovered from your project 🔍")
        prompt_for_schemes(info)
      elsif info.schemes.size > 1
        @ui.important("Multiple schemes were discovered from your project 🔍")
        prompt_for_schemes(info)
      end

      info.export_method = 'development' unless info.export_method
      prompt_for_export_method(info) unless info.export_method_valid?
    end

    def show_fabric_org_help
      @ui.important("\nNavigate to https://www.fabric.io/settings/organizations, select the appropriate organization,")
      @ui.important('and copy the API Key and Build Secret.')
      @shown_fabric_org_help = true
    end

    def prompt_for_api_key(info)
      loop do
        info.api_key = @ui.input("Please provide your Fabric organization's API Key:").strip
        break if info.api_key_valid?
        @ui.message("The API Key you provided was invalid (must be 40 characters).")
      end
    end

    def prompt_for_build_secret(info)
      loop do
        info.build_secret = @ui.input("Please provide your Fabric organization's Build Secret:").strip
        break if info.build_secret_valid?
        @ui.message("The Build Secret you provided was invalid (must be 64 characters).")
      end
    end

    def prompt_for_crashlytics_path(info)
      loop do
        info.crashlytics_path = @ui.input("Please provide the path to Crashlytics.framework:").strip
        break if info.crashlytics_path_valid?
        @ui.message("A submit binary could not be found at the framework path you provided.")
      end
    end

    def prompt_for_email(info)
      loop do
        info.emails = [@ui.input("Please enter an email address to distribute the beta to:").strip]
        break if info.emails_valid?
        @ui.message("You must provide an email address.")
      end
    end

    def prompt_for_schemes(info)
      current_schemes = info.schemes
      if current_schemes.nil? || current_schemes.empty?
        loop do
          info.schemes = [@ui.input("Please enter the name of the scheme you would like to use:").strip]
          break if info.schemes_valid?
          @ui.message("You must provide a scheme name.")
        end
      else
        info.schemes = [@ui.choose("\nWhich scheme would you like to use?", current_schemes)]
      end
    end

    def prompt_for_export_method(info)
      @ui.important("The export method you entered was not valid.")
      info.export_method = @ui.choose("\nWhich export method would you like to use?", CrashlyticsBetaInfo::EXPORT_METHODS)
    end
  end
end
