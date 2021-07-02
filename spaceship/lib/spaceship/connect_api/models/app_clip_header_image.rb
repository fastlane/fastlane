require_relative '../model'

module Spaceship
  class ConnectAPI
    class AppClipHeaderImage
      include Spaceship::ConnectAPI::Model

      attr_accessor :file_size
      attr_accessor :file_name
      attr_accessor :source_file_checksum
      attr_accessor :image_asset
      attr_accessor :asset_token
      attr_accessor :asset_type
      attr_accessor :upload_operations
      attr_accessor :asset_delivery_state
      attr_accessor :uploaded

      attr_mapping(
        'fileSize' => 'file_size',
        'fileName' => 'file_name',
        'sourceFileChecksum' => 'source_file_checksum',
        'imageAsset' => 'image_asset',
        'assetToken' => 'asset_token',
        'assetType' => 'asset_type',
        'uploadOperations' => 'upload_operations',
        'assetDeliveryState' => 'asset_delivery_state',
        'uploaded' => 'uploaded',
      )

      def self.type
        'appClipHeaderImages'
      end

      def self.get(client: nil, app_clip_version_localization_id:)
        client ||= Spaceship::ConnectAPI
        client.get_app_clip_header_images(app_clip_version_localization_id: app_clip_version_localization_id).to_models.first
      end

      def self.create(client: nil, app_clip_version_localization_id:, path:, wait_for_processing: true)
        client ||= Spaceship::ConnectAPI

        filename = File.basename(path)
        filesize = File.size(path)
        bytes = File.binread(path)

        post_attributes = {
          fileSize: filesize,
          fileName: filename
        }

        # Create placeholder to upload header image
        begin
          header_image = client.post_app_clip_header_image(
            app_clip_version_localization_id: app_clip_version_localization_id,
            attributes: post_attributes
          ).to_models.first
        rescue => error
          # Sometimes creating an image with the web session App Store Connect API
          # will result in a false failure. The response will return a 503 but the database
          # insert will eventually go through.
          #
          # When this is observed, we will poll until we find the matching image that
          # is awaiting for upload and file size
          #
          # https://github.com/fastlane/fastlane/pull/16842
          time = Time.now.to_i

          timeout_minutes = (ENV["SPACESHIP_SCREENSHOT_UPLOAD_TIMEOUT"] || 20).to_i

          loop do
            # This error handling needs to be revised since any error occurred can reach here.
            # It should handle errors based on what status code is.
            puts("Waiting for heder image to appear before uploading. This is unlikely to be recovered unless it's 503 error. error=\"#{error}\"")
            sleep(30)

            header_image = get(client: client, app_clip_version_localization_id: app_clip_version_localization_id)
            break if header_image.awaiting_upload? && header_image.file_size == filesize

            time_diff = Time.now.to_i - time
            raise error if time_diff >= (60 * timeout_minutes)
          end
        end

        # Upload the file
        upload_operations = header_image.upload_operations
        Spaceship::ConnectAPI::FileUploader.upload(upload_operations, bytes)

        # Update file uploading complete
        patch_attributes = {
          uploaded: true,
          sourceFileChecksum: Digest::MD5.hexdigest(bytes)
        }

        # Patch screenshot that file upload is complete
        # Catch error if patch retries due to 504. Origal patch
        # may go through by return response as 504.
        begin
          header_image = Spaceship::ConnectAPI.patch_app_clip_header_image(
            app_clip_header_image_id: header_image.id,
            attributes: patch_attributes
          ).to_models.first
        rescue => error
          puts("Failed to patch app screenshot. Update may have gone through so verifying") if Spaceship::Globals.verbose?

          header_image = client.get_app_clip_header_image(app_clip_header_image_id: header_image.id).to_models.first
          raise error unless header_image.complete?
        end

        # Wait for processing
        if wait_for_processing
          loop do
            if header_image.complete?
              puts("Screenshot processing complete!") if Spaceship::Globals.verbose?
              break
            elsif header_image.error?
              messages = ["Error processing screenshot '#{header_image.file_name}'"] + header_image.error_messages
              raise messages.join(". ")
            end

            # Poll every 2 seconds
            sleep_time = 2
            puts("Waiting #{sleep_time} seconds before checking status of processing...") if Spaceship::Globals.verbose?
            sleep(sleep_time)

            header_image = client.get_app_clip_header_image(app_clip_header_image_id: header_image.id).to_models.first
          end
        end

        header_image
      end

      def awaiting_upload?
        (asset_delivery_state || {})["state"] == "AWAITING_UPLOAD"
      end

      def complete?
        (asset_delivery_state || {})["state"] == "COMPLETE"
      end

      def error?
        (asset_delivery_state || {})["state"] == "FAILED"
      end

      def error_messages
        errors = (asset_delivery_state || {})["errors"]
        (errors || []).map do |error|
          [error["code"], error["description"]].compact.join(" - ")
        end
      end

      # This does not download the source image (exact image that was uploaded)
      # This downloads a modified version.
      # This image won't have the same checksums as source_file_checksum.
      #
      # There is an open radar for allowing downloading of source file.
      # https://openradar.appspot.com/radar?id=4980344105205760
      def image_asset_url(width: nil, height: nil, type: "png")
        return nil if image_asset.nil?

        template_url = image_asset["templateUrl"]
        width ||= image_asset["width"]
        height ||= image_asset["height"]

        template_url
          .gsub("{w}", width.to_s)
          .gsub("{h}", height.to_s)
          .gsub("{f}", type)
      end

      def delete!(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        client.delete_app_clip_header_image(app_clip_header_image_id: id)
      end
    end
  end
end
