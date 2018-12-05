require_relative 'portal_base'

module Spaceship
  module Portal
    # Represents an app group of the Apple Dev Portal
    class AppGroup < PortalBase
      # @return (String) The identifier assigned to this group
      # @example
      #   "group.com.example.application"
      attr_accessor :group_id

      # @return (String) The prefix assigned to this group
      # @example
      #   "9J57U9392R"
      attr_accessor :prefix

      # @return (String) The name of this group
      # @example
      #   "App Group"
      attr_accessor :name

      # @return (String) Status of the group
      # @example
      #   "current"
      attr_accessor :status

      # @return (String) The identifier of this app group, provided by the Dev Portal
      # @example
      #   "2MAY7NPHAA"
      attr_accessor :app_group_id

      attr_mapping(
        'applicationGroup' => :app_group_id,
        'name' => :name,
        'prefix' => :prefix,
        'identifier' => :group_id,
        'status' => :status
      )

      class << self
        # @return (Array) Returns all app groups available for this account
        def all
          client.app_groups.map { |group| self.factory(group) }
        end

        # Creates a new App Group on the Apple Dev Portal
        #
        # @param group_id [String] the identifier to assign to this group
        # @param name [String] the name of the group
        # @return (AppGroup) The group you just created
        def create!(group_id: nil, name: nil)
          new_group = client.create_app_group!(name, group_id)
          self.new(new_group)
        end

        # Find a specific App Group group_id
        # @return (AppGroup) The app group you're looking for. This is nil if the app group can't be found.
        def find(group_id)
          all.find do |group|
            group.group_id == group_id
          end
        end
      end

      # Delete this app group
      # @return (AppGroup) The app group you just deletd
      def delete!
        client.delete_app_group!(app_group_id)
        self
      end
    end
  end
end
