require_relative '../model'
module Spaceship
  class ConnectAPI
    class CustomAppOrganization
      include Spaceship::ConnectAPI::Model

      attr_accessor :device_enrollment_program_id
      attr_accessor :name

      attr_mapping({
        "deviceEnrollmentProgramId" => "device_enrollment_program_id",
        "name" => "name"
      })

      def self.type
        return "customAppOrganizations"
      end

      #
      # API
      #

      def self.all(app_id: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        resps = Spaceship::ConnectAPI.get_custom_app_organization(
          app_id: app_id,
          filter: filter,
          includes: includes,
          limit: nil,
          sort: nil
        ).all_pages
        return resps.flat_map(&:to_models)
      end

      def self.create(app_id: nil, device_enrollment_program_id: nil, name: nil)
        return Spaceship::ConnectAPI.post_custom_app_organization(app_id: app_id, device_enrollment_program_id: device_enrollment_program_id, name: name).first
      end

      def delete!
        Spaceship::ConnectAPI.delete_custom_app_organization(custom_app_organization_id: id)
      end
    end
  end
end
