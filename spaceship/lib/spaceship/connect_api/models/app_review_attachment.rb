require_relative '../model'
module Spaceship
  class ConnectAPI
    class AppReviewAttachment
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
        return "appReviewAttachments"
      end

      #
      # API
      #

      def self.create(app_store_review_detail_id: nil, path: nil)
        require 'faraday'

        filename = File.basename(path)
        filesize = File.size(path)
        payload = File.binread(path)

        post_attributes = {
          fileSize: filesize,
          fileName: filename
        }

        post_resp = Spaceship::ConnectAPI.post_app_review_attachment(app_store_review_detail_id: app_store_review_detail_id, attributes: post_attributes).to_models.first

        # {
        #   "method": "PUT",
        #   "url": "https://some-url-apple-gives-us",
        #   "length": 57365,
        #   "offset": 0,
        #   "requestHeaders": [
        #     {
        #       "name": "Content-Type",
        #       "value": "image/png"
        #     }
        #   ]
        # }
        upload_operation = post_resp.upload_operations.first

        headers = {}
        upload_operation["requestHeaders"].each do |hash|
          headers[hash["name"]] = hash["value"]
        end

        Faraday.put(
          upload_operation["url"],
          payload,
          headers
        )

        patch_attributes = {
          uploaded: true,
          sourceFileChecksum: "checksum-holder"
        }

        Spaceship::ConnectAPI.patch_app_review_attachment(app_review_attachment_id: post_resp.id, attributes: patch_attributes).to_models.first
      end

      def delete!(filter: {}, includes: nil, limit: nil, sort: nil)
        Spaceship::ConnectAPI.delete_app_review_attachment(app_review_attachment_id: id)
      end
    end
  end
end
