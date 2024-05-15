module Fastlane
  module Actions
    class GooglePlayTrackRolloutPercentagesAction < Action
      # Define options that are applicable for this action.
      OPTIONS = [
        :package_name,
        :track,
        :key,
        :issuer,
        :json_key,
        :json_key_data,
        :root_url,
        :timeout
      ]

      def self.run(params)
        require 'supply'
        require 'supply/options'
        require 'supply/reader'

        # Configure Supply with parameters
        Supply.config = params

        # Retrieve rollout percentages using the new method in the Reader class
        rollout_percentages = Supply::Reader.new.track_rollout_percentages
        unless rollout_percentages.empty?
          UI.success("Successfully retrieved rollout percentages for track: #{params[:track]}")
        end
        rollout_percentages
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Retrieves rollout percentages for each release in a Google Play track"
      end

      def self.details
        "Use this action to fetch the rollout percentages of all active releases in a specified Google Play track."
      end

      def self.available_options
        require 'supply'
        require 'supply/options'

        # Select only the options needed for this action from Supply options
        Supply::Options.available_options.select do |option|
          OPTIONS.include?(option.key)
        end
      end

      def self.output
        # Define the kind of data that this action returns
        [
          ['GOOGLE_PLAY_TRACK_ROLLOUT_PERCENTAGES', 'A hash containing the rollout percentages of releases']
        ]
      end

      def self.return_value
        "Hash with release names as keys and rollout percentages as values"
      end

      def self.authors
        ["your_username"] # Replace with your Fastlane portal username or handle
      end

      def self.is_supported?(platform)
        platform == :android # Ensure this runs only for Android platform
      end

      def self.example_code
        [
          'google_play_track_rollout_percentages(track: "beta")'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
