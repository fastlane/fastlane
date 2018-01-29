module Spaceship
  class Provider
    attr_accessor :provider_id
    attr_accessor :name
    attr_accessor :content_types

    def initialize(provider_hash: nil)
      self.provider_id = provider_hash['providerId']
      self.name = provider_hash['name']
      self.content_types = provider_hash['contentTypes']
    end
  end
end
