require_relative '../model'
require_relative '../file_uploader'
require_relative './app_screenshot_set'
require 'spaceship/globals'

require 'digest/md5'

module Spaceship
  class ConnectAPI
    class AppScreenshot
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

      attr_mapping({
        "fileSize" => "file_size",
        "fileName" => "file_name",
        "sourceFileChecksum" => "source_file_checksum",
        "imageAsset" => "image_asset",
        "assetToken" => "asset_token",
        "assetType" => "asset_type",
        "uploadOperations" => "upload_operations",
        "assetDeliveryState" => "asset_delivery_state",
        "uploaded" => "uploaded"
      })

      def self.type
        return "appScreenshots"
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

        return template_url
               .gsub("{w}", width.to_s)
               .gsub("{h}", height.to_s)
               .gsub("{f}", type)
      end

      #
      # API
      #
      #

      def self.create(client: nil, app_screenshot_set_id: nil, path: nil, wait_for_processing: true)
        client ||= Spaceship::ConnectAPI
        require 'faraday'

        filename = File.basename(path)
        filesize = File.size(path)
        bytes = File.binread(path)

        post_attributes = {
          fileSize: filesize,
          fileName: filename
        }

        # Create placeholder to upload screenshot
        begin
          screenshot = client.post_app_screenshot(
            app_screenshot_set_id: app_screenshot_set_id,
            attributes: post_attributes
          ).first
        rescue => error
          # Sometimes creating a screenshot with the web session App Store Connect API
          # will result in a false failure. The response will return a 503 but the database
          # insert will eventually go through.
          #
          # When this is observed, we will poll until we find the matching screenshot that
          # is awaiting for upload and file size
          #
          # https://github.com/fastlane/fastlane/pull/16842
          time = Time.now.to_i

          timeout_minutes = (ENV["SPACESHIP_SCREENSHOT_UPLOAD_TIMEOUT"] || 20).to_i

          loop do
            # This error handling needs to be revised since any error occurred can reach here.
            # It should handle errors based on what status code is.
            puts("Waiting for screenshots to appear before uploading. This is unlikely to be recovered unless it's 503 error. error=\"#{error}\"")
            sleep(30)

            screenshots = Spaceship::ConnectAPI::AppScreenshotSet
                          .get(client: client, app_screenshot_set_id: app_screenshot_set_id)
                          .app_screenshots

            screenshot = screenshots.find do |s|
              s.awaiting_upload? && s.file_size == filesize
            end

            break if screenshot

            time_diff = Time.now.to_i - time
            raise error if time_diff >= (60 * timeout_minutes)
          end
        end

        # Upload the file
        upload_operations = screenshot.upload_operations
        Spaceship::ConnectAPI::FileUploader.upload(upload_operations, bytes)

        # Update file uploading complete
        patch_attributes = {
          uploaded: true,
          sourceFileChecksum: Digest::MD5.hexdigest(bytes)
        }

        # Patch screenshot that file upload is complete
        # Catch error if patch retries due to 504. Original patch
        # may go through by return response as 504.
        begin
          screenshot = Spaceship::ConnectAPI.patch_app_screenshot(
            app_screenshot_id: screenshot.id,
            attributes: patch_attributes
          ).first
        rescue => error
          puts("Failed to patch app screenshot. Update may have gone through so verifying") if Spaceship::Globals.verbose?

          screenshot = client.get_app_screenshot(app_screenshot_id: screenshot.id).first
          raise error unless screenshot.complete?
        end

        # Wait for processing
        if wait_for_processing
          loop do
            if screenshot.complete?
              puts("Screenshot processing complete!") if Spaceship::Globals.verbose?
              break
            elsif screenshot.error?
              messages = ["Error processing screenshot '#{screenshot.file_name}'"] + screenshot.error_messages
              raise messages.join(". ")
            end

            # Poll every 2 seconds
            sleep_time = 2
            puts("Waiting #{sleep_time} seconds before checking status of processing...") if Spaceship::Globals.verbose?
            sleep(sleep_time)

            screenshot = client.get_app_screenshot(app_screenshot_id: screenshot.id).first
          end
        end

        return screenshot
      end

      def delete!(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        client.delete_app_screenshot(app_screenshot_id: id)
      end
    end
  end
end
