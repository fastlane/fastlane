module Spaceship
  module Tunes
    # Represents a screenshot hosted on iTunes Connect
    class AppScreenshot

      attr_accessor :thumbnail_url

      attr_accessor :sort_order

      attr_accessor :original_file_name

      attr_accessor :url

      attr_accessor :device_type

      attr_accessor :language

      def initialize(hash)
        self.thumbnail_url = hash[:thumbnail_url]
        self.sort_order = hash[:sort_order]
        self.original_file_name = hash[:original_file_name]
        self.url = hash[:url]
        self.device_type = hash[:device_type]
        self.language = hash[:language]
      end
    end
  end
end
