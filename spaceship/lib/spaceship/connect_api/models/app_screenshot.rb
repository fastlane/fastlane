require_relative '../model'
require_relative '../file_uploader'

require 'digest/md5'

module Spaceship
  class ConnectAPI
    class AppScreenshot
      include Spaceship::ConnectAPI::Model

      attr_accessor :file_name
      attr_accessor :source_file_checksum
      attr_accessor :image_asset
      attr_accessor :asset_token
      attr_accessor :asset_type
      attr_accessor :upload_operations
      attr_accessor :asset_delivery_state
      attr_accessor :uploaded

      attr_mapping({
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

      #
      # API
      #

      def self.create(app_screenshot_set_id: nil, path: nil)
        require 'faraday'

        filename = File.basename(path)
        filesize = File.size(path)
        bytes = File.binread(path)

        post_attributes = {
          fileSize: filesize,
          fileName: filename
        }

        post_resp = Spaceship::ConnectAPI.post_app_screenshot(
          app_screenshot_set_id: app_screenshot_set_id,
          attributes: post_attributes
        ).to_models.first

        upload_operations = post_resp.upload_operations
        Spaceship::ConnectAPI::FileUploader.upload(upload_operations, bytes)

        patch_attributes = {
          uploaded: true,
          sourceFileChecksum: Digest::MD5.hexdigest(bytes)
        }

        Spaceship::ConnectAPI.patch_app_screenshot(
          app_screenshot_id: post_resp.id,
          attributes: patch_attributes
        ).to_models.first
      end

      def delete!(filter: {}, includes: nil, limit: nil, sort: nil)
        Spaceship::ConnectAPI.delete_app_screenshot(app_screenshot_id: id)
      end
    end
  end
end
