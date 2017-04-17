module Testflight
  class Group < Base

    attr_accessor :id
    attr_accessor :name
    attr_accessor :is_default_external_group

    attr_mapping({
      'id' => :id,
      'name' => :name,
      'isDefaultExternalGroup' => :is_default_external_group
    })

    def self.all(provider_id, app_id)
      groups = client.get_groups(provider_id, app_id)
      groups.map { |g| self.new(g) }
    end

    def self.find(provider_id, app_id, group_name)
      groups = self.all(provider_id, app_id)
      groups.find { |g| g.name == group_name }
    end

    def self.default_external_group(provider_id, app_id)
      groups = self.all(provider_id, app_id)
      groups.find { |g| g.default_external_group? }
    end

    def default_external_group?
      is_default_external_group
    end
  end
end
