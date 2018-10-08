module Fastlane
  module Actions
    class UploadToPlayStoreAction < Action
      def self.run(params)
        require 'supply'
        require 'supply/options'

        # If no APK params were provided, try to fill in the values from lane context, preferring
        # the multiple APKs over the single APK if set.
        if params[:apk_paths].nil? && params[:apk].nil?
          all_apk_paths = Actions.lane_context[SharedValues::GRADLE_ALL_APK_OUTPUT_PATHS] || []
          if all_apk_paths.size > 1
            params[:apk_paths] = all_apk_paths
          else
            params[:apk] = Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH]
          end
        end

        # If no AAB param was provided, try to fill in the value from lane context.
        # First GRADLE_ALL_AAB_OUTPUT_PATHS if only one
        # Else from GRADLE_AAB_OUTPUT_PATH
        if params[:aab].nil?
          all_aab_paths = Actions.lane_context[SharedValues::GRADLE_ALL_AAB_OUTPUT_PATHS] || []
          if all_aab_paths.count == 1
            params[:aab] = all_aab_paths.first
          else
            params[:aab] = Actions.lane_context[SharedValues::GRADLE_AAB_OUTPUT_PATH]
          end
        end

        Supply.config = params # we already have the finished config

        Supply::Uploader.new.perform_upload
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload metadata, screenshots and binaries to Google Play (via _supply_)"
      end

      def self.details
        "More information: https://docs.fastlane.tools/actions/supply/"
      end

      def self.available_options
        require 'supply'
        require 'supply/options'
        Supply::Options.available_options
      end

      def self.output
      end

      def self.return_value
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        platform == :android
      end

      def self.example_code
        [
          'upload_to_play_store',
          'supply # alias for "upload_to_play_store"'
        ]
      end

      def self.category
        :production
      end
    end
  end
end
