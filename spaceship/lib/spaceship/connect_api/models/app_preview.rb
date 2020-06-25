require_relative '../model'
require_relative '../file_uploader'

module Spaceship
  class ConnectAPI
    class AppPreview
      include Spaceship::ConnectAPI::Model

      attr_accessor :file_size
      attr_accessor :file_name
      attr_accessor :source_file_checksum
      attr_accessor :preview_frame_time_code
      attr_accessor :mime_type
      attr_accessor :video_url
      attr_accessor :preview_image
      attr_accessor :upload_operations
      attr_accessor :asset_deliver_state
      attr_accessor :upload

      attr_mapping({
        "fileSize" => "file_size",
        "fileName" => "file_name",
        "sourceFileChecksum" => "source_file_checksum",
        "previewFrameTimeCode" => "preview_frame_time_code",
        "mimeType" => "mime_type",
        "videoUrl" => "video_url",
        "previewImage" => "preview_image",
        "uploadOperations" => "upload_operations",
        "assetDeliveryState" => "asset_delivery_state",
        "uploaded" => "uploaded"
      })

      def self.type
        return "appPreviews"
      end

      #
      # API
      #

      def self.create(app_preview_set_id: nil, path: nil)
        require 'faraday'

        filename = File.basename(path)
        filesize = File.size(path)
        payload = File.binread(path)

        post_attributes = {
          fileSize: filesize,
          fileName: filename
        }

        post_resp = Spaceship::ConnectAPI.post_app_preview(
          app_preview_set_id: app_preview_set_id,
          attributes: post_attributes
        ).to_models.first

        upload_operation = post_resp.upload_operations.first
        Spaceship::ConnectAPI::FileUploader.upload(upload_operation, payload)

        patch_attributes = {
          uploaded: true,
          sourceFileChecksum: "checksum-holder"
        }

        Spaceship::ConnectAPI.patch_app_preview(
          app_preview_id: post_resp.id,
          attributes: patch_attributes
        ).to_models.first
      end

      def delete!(filter: {}, includes: nil, limit: nil, sort: nil)
        Spaceship::ConnectAPI.delete_app_preview(app_preview_id: id)
      end
    end
  end
end
