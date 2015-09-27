module Spaceship
  module Tunes
    class AppVersionRef < TunesBase
      attr_accessor :sso_token_for_image
      attr_accessor :sso_token_for_video

      attr_mapping(
        'ssoTokenForImage' => :sso_token_for_image,
        'ssoTokenForVideo' => :sso_token_for_video
      )

      class << self
        def factory(attrs)
          self.new(attrs)
        end
      end
    end
  end
end
