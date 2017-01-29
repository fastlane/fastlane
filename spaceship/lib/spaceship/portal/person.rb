module Spaceship
  module Portal
    class Person < PortalBase
      attr_accessor :person_id
      attr_accessor :firstname
      attr_accessor :lastname
      attr_accessor :email_address
      attr_accessor :developer_status
      attr_accessor :joined
      attr_accessor :team_member_id
      attr_accessor :type

      attr_mapping(
        'personId' => :person_id,
        'firstName' => :firstname,
        'lastName' => :lastname,
        'email' => :email_address,
        'developerStatus' => :developer_status,
        'dateJoined' => :joined,
        'teamMemberId' => :team_member_id
      )

      class << self
        def factory(attrs)
          self.new(attrs)
        end
      end

      def remove!
        client.team_remove_member!(team_member_id)
      end

      def change_role(role)
        client.team_set_role(team_member_id, role)
      end
    end
  end
end
