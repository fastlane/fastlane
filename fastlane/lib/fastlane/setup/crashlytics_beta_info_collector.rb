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
      needs_parsing = needs_parsing?(info)

      if needs_parsing || !info.complete?
        @ui.message "\nTrying to discover Beta by Crashlytics info from your project...".cyan
        parse_project_info_into(info)
        fetch_email_into(info)
      end

      prompt_for_missing_values(info)
    end

    def needs_parsing?(info)
      needs_parsing = false

      if info.crashlytics_path && !info.crashlytics_path_valid?
        @ui.message "The crashlytics_path you provided (#{info.crashlytics_path}) is not valid."
        needs_parsing = true
      end

      if info.api_key && !info.api_key_valid?
        @ui.message "The api_key you provided (#{info.api_key}) is not valid."
        needs_parsing = true
      end

      if info.build_secret && !info.build_secret_valid?
        @ui.message "The build_secret you provided (#{info.build_secret}) is not valid."
        needs_parsing = true
      end

      needs_parsing
    end

    def parse_project_info_into(info)
      begin
        info_hash = @project_parser.parse
      rescue => ex
        @ui.important ex.message
      end

      if info_hash
        info.api_key = info_hash[:api_key] unless info.api_key_valid?
        info.build_secret = info_hash[:build_secret] unless info.build_secret_valid?
        info.crashlytics_path = info_hash[:crashlytics_path] unless info.crashlytics_path_valid?
      end
    end

    def fetch_email_into(info)
      email = @user_email_fetcher.fetch
      info.emails = [email] if !info.emails && email
    end

    def prompt_for_missing_values(info)
      if !info.crashlytics_path || !info.crashlytics_path_valid?
        @ui.important "A Crashlytics submit binary path couldn't be discovered from your project 🔍"
        prompt_for_crashlytics_path(info)
      end

      if !info.api_key || !info.api_key_valid?
        @ui.important "Your Fabric organization's API Key couldn't be discovered from your project 🔍"
        show_fabric_org_help unless @shown_fabric_org_help
        prompt_for_api_key(info)
      end

      if !info.build_secret || !info.build_secret_valid?
        @ui.important "Your Fabric organization's Build Secret couldn't be discovered from your project 🔍"
        show_fabric_org_help unless @shown_fabric_org_help
        prompt_for_build_secret(info)
      end

      if !info.emails || !info.emails_valid?
        @ui.important "Your email address couldn't be discovered from your project 🔍"
        prompt_for_email(info)
      end
    end

    def show_fabric_org_help
      @ui.important("\nNavigate to https://www.fabric.io/settings/organizations, select the appropriate organization,")
      @ui.important('and copy the API Key and Build Secret.')
      @shown_fabric_org_help = true
    end

    def prompt_for_api_key(info)
      loop do
        info.api_key = @ui.ask("\nPlease provide your Fabric organization's API Key:").strip
        break if info.api_key_valid?
        @ui.message "The API Key you provided was invalid (must be 40 characters)."
      end
    end

    def prompt_for_build_secret(info)
      loop do
        info.build_secret = @ui.ask("\nPlease provide your Fabric organization's Build Secret:").strip
        break if info.build_secret_valid?
        @ui.message "The Build Secret you provided was invalid (must be 64 characters)."
      end
    end

    def prompt_for_crashlytics_path(info)
      loop do
        info.crashlytics_path = @ui.ask("\nPlease provide the path to Crashlytics.framework:").strip
        break if info.crashlytics_path_valid?
        @ui.message "A submit binary could not be found at the framework path you provided."
      end
    end

    def prompt_for_email(info)
      loop do
        info.emails = [@ui.ask("\nPlease enter an email address to distribute the beta to:").strip]
        break if info.emails_valid?
        @ui.message "You must provide an email address."
      end
    end
  end
end
