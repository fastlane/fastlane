module Spaceship
  module Tunes
    # Represents an image hosted on iTunes Connect. Used for icons, screenshots, etc
    class AppImage < TunesBase

      attr_accessor :asset_token

      attr_accessor :thumbnail_url

      attr_accessor :sort_order

      attr_accessor :original_file_name

      attr_accessor :url

      attr_mapping(
        'assetToken' => :asset_token,
        'sortOrder' => :sort_order,
        'url' => :url,
        'originalFileName' => :original_file_name,
        'thumbNailUrl' => :thumbnail_url
      )

      class << self
        def factory(attrs)
          self.new(attrs)
        end
      end

      def reset!(attrs = {})
        update_raw_data!(
          {
            asset_token: nil,
            original_file_name: nil,
            sort_order: nil,
            thumbnail_url: nil,
            url: nil
          }.merge(attrs)
        )
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
