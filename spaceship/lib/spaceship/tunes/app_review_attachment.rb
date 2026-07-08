require_relative 'tunes_base'

module Spaceship
  module Tunes
    # Represents an image hosted on App Store Connect. Used for app store review attachment file.
    class AppReviewAttachment < TunesBase
      HOST_URL = "https://iosapps-ssl.itunes.apple.com/itunes-assets"

      attr_accessor :asset_token

      attr_accessor :original_file_name

      attr_accessor :url

      attr_accessor :type_of_file

      attr_mapping(
        'assetToken' => :asset_token,
        'fileType' => :type_of_file,
        'url' => :url,
        'name' => :original_file_name
      )

      def reset!(attrs = {})
        update_raw_data!(
          {
            asset_token: nil,
            type_of_file: nil,
            url: nil,
            original_file_name: nil
          }.merge(attrs)
        )
      end

      def setup
        # Since September 2015 we don't get the url anymore, so we have to manually build it
        self.url = "#{HOST_URL}/#{self.asset_token}"
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
