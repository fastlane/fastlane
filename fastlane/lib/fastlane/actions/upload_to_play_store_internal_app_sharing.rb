module Fastlane
  module Actions
    class UploadToPlayStoreInternalAppSharingAction < Action
      def self.run(params)
        require 'supply'

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

        Supply::Uploader.new.perform_upload_to_internal_app_sharing
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload binaries to Google Play Internal App Sharing (via _supply_)"
      end

      def self.details
        "More information: https://docs.fastlane.tools/actions/upload_to_play_store_internal_app_sharing/"
      end

      def self.available_options
        require 'supply'
        require 'supply/options'
        options = Supply::Options.available_options.clone

        # remove all the unnecessary (for this action) options
        options_to_keep = [:package_name, :apk, :apk_paths, :aab, :aab_paths, :json_key, :json_key_data, :root_url, :timeout]
        options.delete_if { |option| options_to_keep.include?(option.key) == false }
      end

      def self.return_value
        "Returns a string containing the download URL for the uploaded APK/AAB (or array of strings if multiple were uploaded)."
      end

      def self.authors
        ["andrewhavens"]
      end

      def self.is_supported?(platform)
        platform == :android
      end

      def self.example_code
        ["upload_to_play_store_internal_app_sharing"]
      end

      def self.category
        :production
      end
    end
  end
end
