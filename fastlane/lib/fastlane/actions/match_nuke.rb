module Fastlane
  module Actions
    class MatchNukeAction < Action
      def self.run(params)
        require 'match'

        params.load_configuration_file("Matchfile")
        params[:api_key] ||= Actions.lane_context[SharedValues::APP_STORE_CONNECT_API_KEY]

        cert_type = Match.cert_type_sym(params[:type])
        UI.important("Going to revoke your '#{cert_type}' certificate type and provisioning profiles")

        Match::Nuke.new.run(params, type: cert_type)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Easily nuke your certificate and provisioning profiles (via _match_)"
      end

      def self.details
        [
          "Use the match_nuke action to revoke your certificates and provisioning profiles.",
          "Don't worry, apps that are already available in the App Store / TestFlight will still work.",
          "Builds distributed via Ad Hoc or Enterprise will be disabled after nuking your account, so you'll have to re-upload a new build.",
          "After clearing your account you'll start from a clean state, and you can run match to generate your certificates and profiles again.",
          "More information: https://docs.fastlane.tools/actions/match/"
        ].join("\n")
      end

      def self.available_options
        require 'match'
        Match::Options.available_options
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'match_nuke(type: "development")', # See all other options https://github.com/fastlane/fastlane/blob/master/match/lib/match/module.rb#L23
          'match_nuke(type: "development", api_key: app_store_connect_api_key)'
        ]
      end

      def self.authors
        ["crazymanish"]
      end

      def self.category
        :code_signing
      end
    end
  end
end
