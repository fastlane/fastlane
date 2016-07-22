module Fastlane
  class CrashlyticsBetaInfoCollector
    def initialize(project_parser, user_email_fetcher) # other collaborators?
      @project_parser = project_parser
      @user_email_fetcher = user_email_fetcher
      @shown_fabric_org_help = false
    end

    # @param info CrashlyticsBetaInfo to supplement with needed info that is collected
    def collect_info_into(info)
      needs_parsing = needs_parsing?(info)

      if needs_parsing || !info.api_key || !info.build_secret || !info.crashlytics_path || !info.emails
        UI.message "\nfastlane will now try to discover Beta by Crashlytics info from your project."
        parse_project_info_into(info)
        fetch_email_into(info)
      end

      if !info.crashlytics_path || !info.crashlytics_path_valid?
        UI.important "fastlane couldn't determine the Crashlytics submit binary path from your project 🔍"
        prompt_for_crashlytics_path(info)
      end

      if !info.api_key || !info.api_key_valid?
        UI.important "fastlane couldn't find your Fabric organization's API Key from your project 🔍"
        show_fabric_org_help unless @shown_fabric_org_help
        prompt_for_api_key(info)
      end

      if !info.build_secret || !info.build_secret_valid?
        UI.important "fastlane couldn't find your Fabric organization's Build Secret from your project 🔍"
        show_fabric_org_help unless @shown_fabric_org_help
        prompt_for_build_secret(info)
      end

      if !info.emails || !info.emails_valid?
        UI.important "fastlane couldn't find your email address 🔍"
        prompt_for_email(info)
      end

      UI.success "\nBeta by Crashlytics info found 🔑"
    end

    def show_fabric_org_help
      UI.important("\nNavigate to https://www.fabric.io/settings/organizations, select the appropriate organization,")
      UI.important('and copy the API Key and Build Secret.')
      @shown_fabric_org_help = true
    end

    def prompt_for_api_key(info)
      loop do
        info.api_key = UI.ask("\nPlease provide your Fabric organization's API Key:").strip
        break if info.api_key_valid?
        UI.message "The API Key you provided was invalid (must be 40 characters)."
      end
    end

    def prompt_for_build_secret(info)
      loop do
        info.build_secret = UI.ask("\nPlease provide your Fabric organization's Build Secret:").strip
        break if info.build_secret_valid?
        UI.message "The Build Secret you provided was invalid (must be 64 characters)."
      end
    end

    def prompt_for_crashlytics_path(info)
      loop do
        info.crashlytics_path = UI.ask("\nPlease provide the path to Crashlytics.framework:").strip
        break if info.crashlytics_path_valid?
        UI.message "A submit binary could not be found at the framework path you provided."
      end
    end

    def prompt_for_email(info)
      loop do
        info.emails = [UI.ask("\nPlease enter an email address to distribute the beta to:").strip]
        break if info.emails_valid?
        UI.message "You must provide an email address."
      end
    end

    def parse_project_info_into(info)
      begin
        info_hash = @project_parser.parse
      rescue => ex
        UI.important ex.message
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

    def needs_parsing?(info)
      needs_parsing = false

      if info.crashlytics_path && !info.crashlytics_path_valid?
        UI.message "The crashlytics_path you provided (#{info.crashlytics_path}) is not valid."
        needs_parsing = true
      end

      if info.api_key && !info.api_key_valid?
        UI.message "The api_key you provided (#{info.api_key}) is not valid."
        needs_parsing = true
      end

      if info.build_secret && !info.build_secret_valid?
        UI.message "The build_secret you provided (#{info.build_secret}) is not valid."
        needs_parsing = true
      end

      needs_parsing
    end
  end
end
