module Fastlane
  module Actions
    module SharedValues
      MATCH_PROVISIONING_PROFILE_MAPPING = :MATCH_PROVISIONING_PROFILE_MAPPING
    end

    class SyncCodeSigningAction < Action
      def self.run(params)
        require 'match'

        params.load_configuration_file("Matchfile")
        Match::Runner.new.run(params)

        define_profile_type(params)
        define_provisioning_profile_mapping(params)
      end

      def self.define_profile_type(params)
        profile_type = "app-store"
        profile_type = "ad-hoc" if params[:type] == 'adhoc'
        profile_type = "development" if params[:type] == 'development'
        profile_type = "enterprise" if params[:type] == 'enterprise'

        UI.message("Setting Provisioning Profile type to '#{profile_type}'")

        Actions.lane_context[SharedValues::SIGH_PROFILE_TYPE] = profile_type
      end

      # Maps the bundle identifier to the appropriate provisioning profile
      # This is used in the _gym_ action as part of the export options
      # e.g.
      #
      #   export_options: {
      #     provisioningProfiles: { "me.themoji.app.beta": "match AppStore me.themoji.app.beta" }
      #   }
      #
      def self.define_provisioning_profile_mapping(params)
        mapping = Actions.lane_context[SharedValues::MATCH_PROVISIONING_PROFILE_MAPPING] || {}

        # Array (...) to make sure it's an Array, Ruby is magic, try this
        #   Array(1)      # => [1]
        #   Array([1, 2]) # => [1, 2]
        Array(params[:app_identifier]).each do |app_identifier|
          env_variable_name = Match::Utils.environment_variable_name_profile_name(app_identifier: app_identifier,
                                                                                            type: Match.profile_type_sym(params[:type]),
                                                                                        platform: params[:platform])
          mapping[app_identifier] = ENV[env_variable_name]
        end

        Actions.lane_context[SharedValues::MATCH_PROVISIONING_PROFILE_MAPPING] = mapping
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Easily sync your certificates and profiles across your team (via _match_)"
      end

      def self.details
        "More information: https://docs.fastlane.tools/actions/match/"
      end

      def self.available_options
        require 'match'
        Match::Options.available_options
      end

      def self.output
        []
      end

      def self.return_value
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.example_code
        [
          'sync_code_signing(type: "appstore", app_identifier: "tools.fastlane.app")',
          'sync_code_signing(type: "development", readonly: true)',
          'sync_code_signing(app_identifier: ["tools.fastlane.app", "tools.fastlane.sleepy"])',
          'match   # alias for "sync_code_signing"'
        ]
      end

      def self.category
        :code_signing
      end
    end
  end
end
