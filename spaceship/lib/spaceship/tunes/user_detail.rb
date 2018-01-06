require_relative 'tunes_base'

module Spaceship
  module Tunes
    class UserDetail < TunesBase
      attr_accessor :content_provider_id
      attr_accessor :ds_id # used for the team selection (https://github.com/fastlane/fastlane/issues/6711)

      attr_mapping(
        'contentProviderId' => :content_provider_id,
        'sessionToken.dsId' => :ds_id
      )
    end
  end
end
