module Fastlane
  module Actions
    require 'fastlane/actions/build_app'
    class BuildMacAppAction < BuildAppAction
      # Gym::Options.available_options keys that don't apply to mac apps.
      REJECT_OPTIONS = [
        :ipa,
        :skip_package_ipa,
        :catalyst_platform
      ]

      def self.run(params)
        # Adding reject options back in  so gym has everything it needs
        params.available_options += Gym::Options.available_options.select do |option|
          REJECT_OPTIONS.include?(option.key)
        end

        # Defaulting to mac specific values
        params[:catalyst_platform] = "macos"

        super(params)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.available_options
        require 'gym'
        require 'gym/options'

        Gym::Options.available_options.reject do |option|
          REJECT_OPTIONS.include?(option.key)
        end
      end

      def self.is_supported?(platform)
        [:mac].include?(platform)
      end

      def self.description
        "Alias for the `build_app` action but only for macOS"
      end
    end
  end
end
