module Fastlane
  module Actions
    class DownloadFromPlayStoreAction < Action
      def self.run(params)
        require 'supply'
        require 'supply/options'

        Supply.config = params # we already have the finished config

        require 'supply/setup'
        Supply::Setup.new.perform_download
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Download metadata and binaries from Google Play (via _supply_)"
      end

      def self.details
        "More information: https://docs.fastlane.tools/actions/download_from_play_store/"
      end

      def self.available_options
        require 'supply'
        require 'supply/options'
        options = Supply::Options.available_options.clone

        # remove all the unnecessary (for this action) options
        options_to_keep = [:package_name, :metadata_path, :json_key, :json_key_data, :root_url, :timeout, :key, :issuer]
        options.delete_if { |option| options_to_keep.include?(option.key) == false }
      end

      def self.output
      end

      def self.return_value
      end

      def self.authors
        ["janpio"]
      end

      def self.is_supported?(platform)
        platform == :android
      end

      def self.example_code
        [
          'download_from_play_store'
        ]
      end

      def self.category
        :production
      end
    end
  end
end
