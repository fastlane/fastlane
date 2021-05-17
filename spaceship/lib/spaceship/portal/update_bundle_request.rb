module Spaceship
  module Portal
    class JSONApiBase

      attr_accessor :type, :id, :attributes, :relationships

      def initialize
        @type = nil;
        @id = nil;
        @attributes = {};
        @relationships = {};
      end

      def to_hash
        hash = {}
        self.instance_variables.each {|var| hash[var.to_s.delete("@")] = self.instance_variable_get(var) }
        return hash
      end
    end

    class UpdateBundleRequest < JSONApiBase

      def initialize (app, service)
        self.type = "bundleIds"
        self.id = app.app_id
        self.attributes = {
          identifier: app.bundle_id,
          permissions:
          {
            edit: true,
            delete: false
          },
          seedId: app.prefix,
          name: app.name,
          wildcard: app.is_wildcard,
          teamId: app.prefix
        }

        self.relationships = {
          bundleIdCapabilities: {
            data: [BundleIdCapability.new(service).to_hash]
          }
        }

      end
    end

    class BundleIdCapability < JSONApiBase

      def initialize (service)
        self.type = "bundleIdCapabilities"
        self.attributes = {
                            enabled: service.value,
                            settings:service.capability_settings
                          }
        self.relationships = {
            capability: {
                data: {
                    type: "capabilities",
                    id: service.service_id
                }
            }
        }
      end
    end
  end
end
