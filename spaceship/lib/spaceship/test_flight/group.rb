module Spaceship::TestFlight
  class Group < Base
    attr_accessor :id
    attr_accessor :name
    attr_accessor :is_default_external_group

    attr_accessor :app_id

    attr_mapping({
      'id' => :id,
      'name' => :name,
      'isDefaultExternalGroup' => :is_default_external_group
    })

    def self.all(app_id: nil)
      groups = client.get_groups(app_id: app_id)
      groups.map do |g|
        current_element = self.new(g)
        current_element.app_id = app_id
        current_element
      end
    end

    def self.find(app_id: nil, group_name: nil)
      groups = self.all(app_id: app_id)
      groups.find { |g| g.name == group_name }
    end

    def self.default_external_group(app_id: nil)
      groups = self.all(app_id: app_id)
      groups.find(&:default_external_group?)
    end

    def self.filter_groups(app_id: nil, &block)
      groups = self.all(app_id: app_id)
      groups.select(&block)
    end

    def add_tester!(tester)
      client.add_tester_to_group!(group: self, tester: tester, app_id: self.app_id)
    end

    def remove_tester!(tester)
      client.remove_tester_from_group!(group: self, tester: tester, app_id: self.app_id)
    end

    def default_external_group?
      is_default_external_group
    end
  end
end
