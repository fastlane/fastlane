require_relative '../model'
require_relative './actor'
require_relative './review_rejection'

module Spaceship
  class ConnectAPI
    class ResolutionCenterMessage
      include Spaceship::ConnectAPI::Model

      attr_accessor :message_body
      attr_accessor :created_date
      attr_accessor :rejections
      attr_accessor :from_actor

      attr_mapping({
        messageBody: 'message_body',
        createdDate: 'created_date',

        # includes
        rejections: 'rejections',
        fromActor: 'from_actor'
      })

      def self.type
        return 'resolutionCenterMessages'
      end
    end
  end
end
