module Fastlane
	class CrashlyticsBetaInfoCollector

    def initialize(project_parser) # other collaborators?
      @project_parser = project_parser
    end

    # @param info CrashlyticsBetaInfo to supplement with needed info that is collected
    def collect_info_into(info)
      needs_parsing = false
      shown_fabric_org_help = false

      if info.api_key && !info.api_key_valid?
        UI.message "The api_key you provided (#{info.api_key}) is not valid."
        needs_parsing = true
      end

      if info.build_secret && !info.build_secret_valid?
        UI.message "The build_secret you provided (#{info.build_secret}) is not valid."
        needs_parsing = true
      end

      if needs_parsing || !info.api_key || !info.build_secret
        parse_project_info_into(info)
      end

      if !info.api_key || !info.api_key_valid?
        UI.message "Couldn't retrieve your Fabric organization's API Key from your project"

        loop do
          info.api_key = UI.ask "Please provide your Fabric organization's API Key:"
          break if info.api_key_valid?
          UI.message "The API Key you provided was invalid (must be 40 characters)"
        end
      else
        UI.message "API key found: #{info.api_key}"
      end

      if !info.build_secret || !info.build_secret_valid?
        UI.message "Couldn't retrieve your Fabric organization's Build Secret from your project"

        loop do
          info.build_secret = UI.ask "Please provide your Fabric organization's Build Secret:"
          break if info.build_secret_valid?
          UI.message "The Build Secret you provided was invalid (must be 64 characters)"
        end
      else
        UI.message "Build secret found: #{info.build_secret}"
      end

      # UI.important('fastlane was unable to detect your Fabric API Key and Build Secret. 🔑')
      # UI.important('Navigate to https://www.fabric.io/settings/organizations, select the appropriate organization,')
      # UI.important('and copy the API Key and Build Secret.')
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
