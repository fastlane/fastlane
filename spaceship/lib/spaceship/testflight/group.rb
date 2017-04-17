module Testflight
  class Group < Base

    attr_accessor :id
    attr_accessor :name

    attr_mapping({
      'id' => :id,
      'name' => :name
    })

    def self.all(provider_id, app_id)
      groups = client.get_groups(provider_id, app_id)
      groups.map { |g| self.new(g) }
    end

    def self.find(provider_id, app_id, group_name)
      groups = self.all(provider_id, app_id)
      groups.find { |g| g.name == group_name }
    end

  end
end