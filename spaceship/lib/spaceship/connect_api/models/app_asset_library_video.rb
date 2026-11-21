require_relative '../model'
require_relative '../file_uploader'

module Spaceship
  class ConnectAPI
    class AppAssetLibraryVideo
      include Spaceship::ConnectAPI::Model

      attr_mapping({
        'fileSize' => 'file_size',
        'fileName' => 'file_name',
        'category' => 'category',
        'referenceName' => 'reference_name',
        'videoAsset' => 'video_asset',
        'previewFrameTimeCode' => 'preview_frame_time_code',
        'previewFrameImage' => 'preview_frame_image',
        'specId' => 'spec_id',
        'state' => 'state',
        'stateDetails' => 'state_details',
        'uploadOperations' => 'upload_operations'
      })

      def self.type
        return 'appAssetLibraryVideos'
      end

      def complete?
        %w[PREPARE_FOR_SUBMISSION READY_FOR_REVIEW WAITING_FOR_REVIEW IN_REVIEW ACCEPTED APPROVED].include?(state)
      end

      def error?
        %w[FAILED REJECTED ARCHIVED].include?(state)
      end

      def self.get(client: nil, app_asset_library_video_id:)
        client ||= Spaceship::ConnectAPI
        return client.get_app_asset_library_video(app_asset_library_video_id: app_asset_library_video_id).first
      end

      def self.create(client: nil, app_asset_library_id:, path:, category: 'CREATIVE_ASSETS', reference_name: nil, preview_frame_time_code: nil, wait_for_processing: true, processing_timeout: 600, poll_interval: 2)
        client ||= Spaceship::ConnectAPI
        raise ArgumentError, 'processing_timeout and poll_interval must be positive' unless processing_timeout > 0 && poll_interval > 0

        bytes = File.binread(path)
        attributes = { fileName: File.basename(path), fileSize: bytes.bytesize, category: category }
        attributes[:referenceName] = reference_name unless reference_name.nil?
        attributes[:previewFrameTimeCode] = preview_frame_time_code unless preview_frame_time_code.nil?
        video = client.post_app_asset_library_video(app_asset_library_id: app_asset_library_id, attributes: attributes).first
        Spaceship::ConnectAPI::FileUploader.upload(video.upload_operations, bytes)

        # Asset library commits accept uploaded alone, unlike the legacy appPreviews flow.
        video = client.patch_app_asset_library_video(app_asset_library_video_id: video.id, attributes: { uploaded: true }).first
        return video unless wait_for_processing

        deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + processing_timeout
        loop do
          raise "Error processing asset library video '#{video.id}': #{video.state} #{video.state_details}" if video.error?

          frame = video.preview_frame_image || {}
          raise "Error processing preview frame for asset library video '#{video.id}': #{frame}" if frame['state'] == 'FAILED'
          return video if video.complete? && frame['state'] == 'COMPLETE'

          remaining = deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
          raise "Timed out processing asset library video '#{video.id}'. Check its state before uploading again." if remaining <= 0

          sleep([poll_interval, remaining].min)
          video = get(client: client, app_asset_library_video_id: video.id)
        end
      end
    end
  end
end
