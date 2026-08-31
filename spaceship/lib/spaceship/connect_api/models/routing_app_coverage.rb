require_relative '../model'
require_relative '../file_uploader'
require 'digest/md5'

module Spaceship
  class ConnectAPI
    class RoutingAppCoverage
      include Spaceship::ConnectAPI::Model

      attr_accessor :file_size
      attr_accessor :file_name
      attr_accessor :source_file_checksum
      attr_accessor :upload_operations
      attr_accessor :asset_delivery_state
      attr_accessor :uploaded

      attr_mapping({
        "fileSize" => "file_size",
        "fileName" => "file_name",
        "sourceFileChecksum" => "source_file_checksum",
        "uploadOperations" => "upload_operations",
        "assetDeliveryState" => "asset_delivery_state",
        "uploaded" => "uploaded"
      })

      def self.type
        return "routingAppCoverages"
      end

      #
      # API
      #

      def self.create(client: nil, app_store_version_id: nil, path: nil)
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
        routing_app_coverage = client.post_routing_app_coverage(
          app_store_version_id: app_store_version_id,
          attributes: post_attributes
        ).to_models.first

        # Upload the file
        upload_operations = routing_app_coverage.upload_operations
        Spaceship::ConnectAPI::FileUploader.upload(upload_operations, bytes)

        # Update file uploading complete
        patch_attributes = {
          uploaded: true,
          sourceFileChecksum: Digest::MD5.hexdigest(bytes)
        }

        client.patch_routing_app_coverage(
          routing_app_coverage_id: routing_app_coverage.id,
          attributes: patch_attributes
        ).to_models.first
      end

      def delete!(client: nil)
        client ||= Spaceship::ConnectAPI
        client.delete_routing_app_coverage(routing_app_coverage_id: id)
      end
    end
  end
end
