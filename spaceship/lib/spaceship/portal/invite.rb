require_relative 'portal_base'

module Spaceship
  module Portal
    class Invite < PortalBase
      # @return (String) Invite Id
      attr_accessor :invite_id

      # @return (String) Inviter name
      attr_accessor :inviter_name

      # @return (String) Recipient Email Address
      attr_accessor :email_address

      # @return (String) Role (member, admin or agent)
      attr_accessor :type

      # @return (String) Invite creation date
      attr_accessor :created

      # @return (String) Invite expiration date
      attr_accessor :expires

      attr_mapping(
        'inviteId' => :invite_id,
        'inviterName' => :inviter_name,
        'recipientEmail' => :email_address,
        'recipientRole' => :type,
        'dateCreated' => :created,
        'dateExpires' => :expires
      )

      class << self
        def factory(attrs)
          begin
            attrs['dateCreated'] = Time.at(attrs['dateCreated'] / 1000).utc
          rescue NoMethodError
            # if attrs['dateCreated'] does not implement /
          rescue TypeError
            # if Time.at receives an invalid type
          end
          begin
            attrs['dateExpires'] = Time.at(attrs['dateExpires'] / 1000).utc
          rescue NoMethodError
          rescue TypeError
          end
          attrs['recipientRole'] = attrs['recipientRole'].downcase
          return self.new(attrs)
        end
      end
    end
  end
end
