module Spaceship
  module Portal
    class JSONApiBase

      attr_accessor :type, :id, :attributes, :relationships, :data

      def initialize (type: nil, id: nil, attributes: nil, relationships: nil, data: nil)
        @type = type
        @id = id
        @attributes = attributes
        @relationships = relationships
        @data = data
      end

      def to_hash
        hash = {}
        self.instance_variables.each {|var|
          say "\nVAR: #{var}"
          say "\nVAR: #{self.instance_variable_get(var)}"
          if !self.instance_variable_get(var).nil? 
            hash[var.to_s.delete("@")] = self.instance_variable_get(var) 
          end
        }
        return hash
      end
    end

    class UpdateBundleRequest < JSONApiBase

      def initialize (app, service)
        attributes = {
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

        relationships = {
          bundleIdCapabilities: JSONApiBase.new(data: [BundleIdCapability.new(service).to_hash]).to_hash
        }
        super(type: "bundleIds", id: app.app_id, attributes: attributes, relationships: relationships)
      end
    end

    class BundleIdCapability < JSONApiBase

      def initialize (service)
        attributes = {
          enabled: service.value,
          settings:service.capability_settings
        }
        relationships = {
          capability: JSONApiBase.new(type: "capabilities", id: service.service_id).to_hash
        }
        super(type: "bundleIdCapabilities", attributes: attributes, relationships: relationships)
      end
    end
  end
end
