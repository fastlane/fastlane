require_relative '../model'
require_relative '../file_uploader'

module Spaceship
  class ConnectAPI
    class AppAssetLibraryImage
      include Spaceship::ConnectAPI::Model

      attr_mapping({
        'fileSize' => 'file_size',
        'fileName' => 'file_name',
        'category' => 'category',
        'referenceName' => 'reference_name',
        'imageAsset' => 'image_asset',
        'specId' => 'spec_id',
        'state' => 'state',
        'stateDetails' => 'state_details',
        'uploadOperations' => 'upload_operations'
      })

      def self.type
        return 'appAssetLibraryImages'
      end

      def complete?
        %w[PREPARE_FOR_SUBMISSION READY_FOR_REVIEW WAITING_FOR_REVIEW IN_REVIEW ACCEPTED APPROVED].include?(state)
      end

      def error?
        %w[FAILED REJECTED ARCHIVED].include?(state)
      end

      def self.get(client: nil, app_asset_library_image_id:)
        client ||= Spaceship::ConnectAPI
        return client.get_app_asset_library_image(app_asset_library_image_id: app_asset_library_image_id).first
      end

      def self.create(client: nil, app_asset_library_id:, path:, category: 'CREATIVE_ASSETS', reference_name: nil, wait_for_processing: true, processing_timeout: 300, poll_interval: 2)
        client ||= Spaceship::ConnectAPI
        raise ArgumentError, 'processing_timeout and poll_interval must be positive' unless processing_timeout > 0 && poll_interval > 0

        bytes = File.binread(path)
        attributes = { fileName: File.basename(path), fileSize: bytes.bytesize, category: category }
        attributes[:referenceName] = reference_name unless reference_name.nil?
        image = client.post_app_asset_library_image(app_asset_library_id: app_asset_library_id, attributes: attributes).first
        Spaceship::ConnectAPI::FileUploader.upload(image.upload_operations, bytes)

        # The App Asset Library commit does not accept sourceFileChecksum.
        image = client.patch_app_asset_library_image(app_asset_library_image_id: image.id, attributes: { uploaded: true }).first
        return image unless wait_for_processing

        deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + processing_timeout
        loop do
          return image if image.complete?
          raise "Error processing asset library image '#{image.id}': #{image.state} #{image.state_details}" if image.error?

          remaining = deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
          raise "Timed out processing asset library image '#{image.id}'. Check its state before uploading again." if remaining <= 0

          sleep([poll_interval, remaining].min)
          image = get(client: client, app_asset_library_image_id: image.id)
        end
      end
    end
  end
end
