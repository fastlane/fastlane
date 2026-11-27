require_relative '../model'

module Spaceship
  class ConnectAPI
    class ResolutionCenterThread
      include Spaceship::ConnectAPI::Model

      attr_accessor :state
      attr_accessor :can_developer_add_node
      attr_accessor :objectionable_content
      attr_accessor :thread_type
      attr_accessor :created_date
      attr_accessor :last_message_response_date

      attr_accessor :resolution_center_messages
      attr_accessor :app_store_version

      module ThreadType
        REJECTION_BINARY = 'REJECTION_BINARY'
        REJECTION_METADATA = 'REJECTION_METADATA'
        REJECTION_REVIEW_SUBMISSION = 'REJECTION_REVIEW_SUBMISSION'
        APP_MESSAGE_ARC = 'APP_MESSAGE_ARC'
        APP_MESSAGE_ARB = 'APP_MESSAGE_ARB'
        APP_MESSAGE_COMM = 'APP_MESSAGE_COMM'
      end

      attr_mapping({
        state: 'state',
        canDeveloperAddNote: 'can_developer_add_node',
        objectionableContent: 'objectionable_content',
        threadType: 'thread_type',
        createdDate: 'created_date',
        lastMessageResponseDate: 'last_message_response_date',

        # includes
        resolutionCenterMessages: 'resolution_center_messages',
        appStoreVersion: 'app_store_version'
      })

      def self.type
        return "resolutionCenterThreads"
      end

      #
      # API
      #

      def self.all(client: nil, filter:, includes: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_resolution_center_threads(filter: filter, includes: includes).all_pages
        return resps.flat_map(&:to_models)
      end

      def fetch_messages(client: nil, filter: {}, includes: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_resolution_center_messages(thread_id: id, filter: filter, includes: includes).all_pages
        return resps.flat_map(&:to_models)
      end

      def fetch_rejection_reasons(client: nil, includes: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.get_review_rejection(filter: { 'resolutionCenterMessage.resolutionCenterThread': id }, includes: includes)
        return resp.to_models
      end
    end
  end
end
