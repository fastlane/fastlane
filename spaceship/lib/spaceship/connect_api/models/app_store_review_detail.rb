require_relative '../model'
require_relative './app_store_review_attachment'

module Spaceship
  class ConnectAPI
    class AppStoreReviewDetail
      include Spaceship::ConnectAPI::Model

      attr_accessor :contact_first_name
      attr_accessor :contact_last_name
      attr_accessor :contact_phone
      attr_accessor :contact_email
      attr_accessor :demo_account_name
      attr_accessor :demo_account_password
      attr_accessor :demo_account_required
      attr_accessor :notes

      attr_accessor :app_store_review_attachments

      attr_mapping({
        "contactFirstName" => "contact_first_name",
        "contactLastName" => "contact_last_name",
        "contactPhone" => "contact_phone",
        "contactEmail" => "contact_email",
        "demoAccountName" => "demo_account_name",
        "demoAccountPassword" => "demo_account_password",
        "demoAccountRequired" => "demo_account_required",
        "notes" => "notes",

        "appStoreReviewAttachments" => "app_store_review_attachments"
      })

      def self.type
        return "appStoreReviewDetails"
      end

      #
      # API
      #

      def update(client: nil, attributes: nil)
        client ||= Spaceship::ConnectAPI
        attributes = reverse_attr_mapping(attributes)
        return client.patch_app_store_review_detail(app_store_review_detail_id: id, attributes: attributes)
      end

      def upload_attachment(client: nil, path: nil)
        client ||= Spaceship::ConnectAPI
        return client::AppStoreReviewAttachment.create(app_store_review_detail_id: id, path: path)
      end
    end
  end
end
