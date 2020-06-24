require_relative '../model'
require_relative '../file_uploader'

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

      # "fileSize": 92542,
      #   "fileName": "ftl_3241d62418767c0aa9b889b020c4f8db_45455763d4aaf7b18ee0045bc787f3de.png",
      #   "sourceFileChecksum": "c237fd7852ed8f9285d16d9a28d2ec25",
      #   "imageAsset": {
      #     "templateUrl": "https://is4-ssl.mzstatic.com/image/thumb/Purple113/v4/61/18/68/61186886-b234-5bd0-1f4a-563124f18511/pr_source.png/{w}x{h}bb.{f}",
      #     "width": 2048,
      #     "height": 2732
      #   },
      #   "assetToken": "Purple113/v4/61/18/68/61186886-b234-5bd0-1f4a-563124f18511/pr_source.png",
      #   "assetType": "SortedJ99ScreenShot",
      #   "uploadOperations": null,
      #   "assetDeliveryState": {
      #     "errors": [],
      #     "warnings": null,
      #     "state": "COMPLETE"
      #   },
      #   "uploaded": null

      # "assetDeliveryState": {
      #   "errors": [],
      #   "warnings": null,
      #   "state": "AWAITING_UPLOAD"
      # },

      # "assetDeliveryState": {
      #   "errors": [],
      #   "warnings": null,
      #   "state": "UPLOAD_COMPLETE"
      # },

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
        payload = File.binread(path)

        post_attributes = {
          fileSize: filesize,
          fileName: filename
        }

        post_resp = Spaceship::ConnectAPI.post_app_screenshot(app_screenshot_set_id: app_screenshot_set_id, attributes: post_attributes).to_models.first

        upload_operation = post_resp.upload_operations.first
        Spaceship::ConnectAPI::FileUploader.upload(upload_operation, payload)

        patch_attributes = {
          uploaded: true,
          sourceFileChecksum: "checksum-holder"
        }

        Spaceship::ConnectAPI.patch_app_screenshot(app_screenshot_id: post_resp.id, attributes: patch_attributes).to_models.first
      end

      def delete!(filter: {}, includes: nil, limit: nil, sort: nil)
        Spaceship::ConnectAPI.delete_app_screenshot(app_screenshot_id: id)
      end
    end
  end
end
