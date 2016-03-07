module Spaceship
  module Tunes
    class UserDetail < TunesBase
      attr_accessor :content_provider_id

      attr_mapping(
        'contentProviderId' => :content_provider_id
      )

      class << self
        def factory(attrs)
          self.new(attrs)
        end
      end
    end
  end
end
