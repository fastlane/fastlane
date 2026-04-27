module Fastlane
  module Actions
    class GooglePlayTrackMetaAction < Action
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

        Supply.config = params

        Supply::Reader.new.track_meta
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Retrieves track metadata for a Google Play track"
      end

      def self.details
        "More information: [https://docs.fastlane.tools/actions/supply/](https://docs.fastlane.tools/actions/supply/)"
      end

      def self.available_options
        require 'supply'
        require 'supply/options'

        Supply::Options.available_options.select do |option|
          OPTIONS.include?(option.key)
        end
      end

      def self.output
      end

      def self.return_value
        "A Track object containing the track name and releases for the given Google Play track (see https://developers.google.com/android-publisher/api-ref/rest/v3/edits.tracks)"
      end

      def self.authors
        ["tshedor"]
      end

      def self.is_supported?(platform)
        platform == :android
      end

      def self.example_code
        [
          'google_play_track_meta',
          'google_play_track_meta(track: "beta")'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
