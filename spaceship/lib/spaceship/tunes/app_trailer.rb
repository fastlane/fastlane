require_relative 'tunes_base'

module Spaceship
  module Tunes
    # Represents a preview video hosted on iTunes Connect. Used for icons, screenshots, etc
    class AppTrailer < TunesBase
      attr_accessor :video_asset_token

      attr_accessor :picture_asset_token

      attr_accessor :descriptionXML

      attr_accessor :preview_frame_time_code

      attr_accessor :video_url

      attr_accessor :preview_image_url

      attr_accessor :full_sized_preview_image_url

      attr_accessor :device_type

      attr_accessor :language

      attr_mapping(
        'videoAssetToken' => :video_asset_token,
        'pictureAssetToken' => :picture_asset_token,
        'descriptionXML' => :descriptionXML,
        'previewFrameTimeCode' => :preview_frame_time_code,
        'isPortrait' => :is_portrait,
        'videoUrl' => :video_url,
        'previewImageUrl' => :preview_image_url,
        'fullSizedPreviewImageUrl' => :full_sized_preview_image_url,
        'contentType' => :content_type,
        'videoStatus' => :video_status
      )

      def reset!(attrs = {})
        update_raw_data!({
          video_asset_token: nil,
          picture_asset_token: nil,
          descriptionXML: nil,
          preview_frame_time_code: nil,
          is_portrait: nil,
          video_url: nil,
          preview_image_url: nil,
          full_sized_preview_image_url: nil,
          content_type: nil,
          video_status: nil,
          device_type: nil,
          language: nil
         }.merge(attrs))
      end

      private

      def update_raw_data!(hash)
        hash.each do |k, v|
          self.send("#{k}=", v)
        end
      end
    end
  end
end
