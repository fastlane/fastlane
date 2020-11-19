require_relative '../model'
require_relative '../file_uploader'
require 'digest/md5'

module Spaceship
  class ConnectAPI
    class AppStoreReviewAttachment
      include Spaceship::ConnectAPI::Model

      attr_accessor :file_name
      attr_accessor :source_file_checksum
      attr_accessor :upload_operations
      attr_accessor :asset_delivery_state
      attr_accessor :uploaded

      attr_mapping({
        "fileName" => "file_name",
        "sourceFileChecksum" => "source_file_checksum",
        "uploadOperations" => "upload_operations",
        "assetDeliveryState" => "asset_delivery_state",
        "uploaded" => "uploaded"
      })

      def self.type
        return "appStoreReviewAttachments"
      end

      #
      # API
      #

      def self.create(client: nil, app_store_review_detail_id: nil, path: nil)
        client ||= Spaceship::ConnectAPI
        require 'faraday'

        filename = File.basename(path)
        filesize = File.size(path)
        bytes = File.binread(path)

        post_attributes = {
          fileSize: filesize,
          fileName: filename
        }

        # Create placeholder
        attachment = client.post_app_store_review_attachment(
          app_store_review_detail_id: app_store_review_detail_id,
          attributes: post_attributes
        ).to_models.first

        # Upload the file
        upload_operations = attachment.upload_operations
        Spaceship::ConnectAPI::FileUploader.upload(upload_operations, bytes)

        # Update file uploading complete
        patch_attributes = {
          uploaded: true,
          sourceFileChecksum: Digest::MD5.hexdigest(bytes)
        }

        client.patch_app_store_review_attachment(
          app_store_review_attachment_id: attachment.id,
          attributes: patch_attributes
        ).to_models.first
      end

      def delete!(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        client.delete_app_store_review_attachment(app_store_review_attachment_id: id)
      end
    end
  end
end
