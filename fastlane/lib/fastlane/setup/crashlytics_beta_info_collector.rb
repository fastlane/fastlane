module Fastlane
	class CrashlyticsBetaInfoCollector

    def initialize(project_parser) # other collaborators?
      @project_parser = project_parser
      @shown_fabric_org_help = false
    end

    # @param info CrashlyticsBetaInfo to supplement with needed info that is collected
    def collect_info_into(info)
      needs_parsing = false

      if info.api_key && !info.api_key_valid?
        UI.message "The api_key you provided (#{info.api_key}) is not valid."
        needs_parsing = true
      end

      if info.build_secret && !info.build_secret_valid?
        UI.message "The build_secret you provided (#{info.build_secret}) is not valid."
        needs_parsing = true
      end

      if needs_parsing || !info.api_key || !info.build_secret
        UI.message "\nfastlane will now check your project for Beta by Crashlytics info."
        parse_project_info_into(info)
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

      UI.success "\nFabric API Key and Build Secret found 🔑"
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
        UI.message "The API Key you provided was invalid (must be 40 characters)"
      end
    end

    def prompt_for_build_secret(info)
      loop do
        info.build_secret = UI.ask("\nPlease provide your Fabric organization's Build Secret:").strip
        break if info.build_secret_valid?
        UI.message "The Build Secret you provided was invalid (must be 64 characters)"
      end
    end

    def parse_project_info_into(info)
      begin
        info_hash = @project_parser.parse
      rescue => ex
        UI.important ex.message
      end

      if info_hash
        info.api_key = info_hash[:api_key] if !info.api_key_valid?
        info.build_secret = info_hash[:build_secret] if !info.build_secret_valid?
      end
    end
	end
end
