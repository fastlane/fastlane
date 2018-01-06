require_relative 'member'

module Spaceship
  module Tunes
    class Members < TunesBase
      class << self
        def all
          response = client.members
          return_members = []
          response.each  do |member|
            return_members << Tunes::Member.factory(member)
          end
          return_members
        end

        def find(email)
          all.each do |member|
            if member.email_address == email
              return member
            end
          end
          return nil
        end

        def create!(firstname: nil, lastname: nil, email_address: nil, roles: [], apps: [])
          client.create_member!(firstname: firstname, lastname: lastname, email_address: email_address, roles: roles, apps: apps)
        end

        def update_member_roles!(member, roles: [], apps: [])
          client.update_member_roles!(member, roles: roles, apps: apps)
        end
      end
    end
  end
end
