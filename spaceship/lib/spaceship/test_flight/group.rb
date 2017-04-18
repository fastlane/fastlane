module TestFlight
  class Group < Base
    attr_accessor :id
    attr_accessor :name
    attr_accessor :is_default_external_group

    # TODO: is it ok to have a reference here? Every group is specific to
    # an Spaceship::Application object from my understanding
    # We need a reference to the app to build the complete URLs, for example
    # to add testers to a group. Please remove comment and replace with docs if ok
    attr_accessor :app_id

    attr_mapping({
      'id' => :id,
      'name' => :name,
      'isDefaultExternalGroup' => :is_default_external_group
    })

    def self.all(app_id)
      groups = client.all_groups(app_id)
      groups.map do |g|
        current_element = self.new(g)
        current_element.app_id = app_id
        current_element
      end
    end

    def self.find(app_id, group_name)
      groups = self.all(app_id)
      groups.find { |g| g.name == group_name }
    end

    def self.default_external_group(app_id)
      groups = self.all(app_id)
      groups.find(&:default_external_group?)
    end

    def self.filter_groups(app_id, &block)
      groups = self.all(app_id)
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
