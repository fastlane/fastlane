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

    # First we need to add the tester to the app
    # It's ok if the tester already exists, we just have to do this... don't ask
    # This will enable testing for the tester for a given app, as just creating the tester on an account-level
    # is not enough to add the tester to a group. If this isn't done the next request would fail.
    # This is a bug we reported to the iTunes Connect team, as it also happens on the iTunes Connect UI on 18. April 2017
    def add_tester!(tester)
      # This post request makes the account-level tester available to the app
      client.post_tester(app_id: self.app_id, tester: tester)
      # This put request adds the tester to the group
      client.put_tester_to_group(group_id: self.id, tester_id: tester.tester_id, app_id: self.app_id)
    end

    def remove_tester!(tester)
      client.delete_tester_from_group(group_id: self.id, tester_id: tester.tester_id, app_id: self.app_id)
    end

    def default_external_group?
      is_default_external_group
    end
  end
end
