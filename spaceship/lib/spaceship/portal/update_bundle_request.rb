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
          if self.instance_variable_get(var) != nil
            hash[var.to_s.delete("@")] = self.instance_variable_get(var) 
          end
        }
        say "\nTO_HASH_DEEP:\n#{self.class.to_hash_deep(self)}"
        return hash
      end

      def self.to_hash_deep(var)
        result = {}
        if var.is_a? Hash 
          var.each { |key, value|
            result[key] = self.class.to_hash_deep(value)
          }
        elsif var.is_a? JSONApiBase
          var.instance_variables.each {|v|
            if var.instance_variable_get(v) != nil
              hash[v.to_s.delete("@")] = self.class.to_hash_deep(var.instance_variable_get(v))
            end
          }
        else
          return var
        end
        return result
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
          capability: JSONApiBase.new(data: JSONApiBase.new(type: "capabilities", id: service.service_id).to_hash).to_hash
        }
        super(type: "bundleIdCapabilities", attributes: attributes, relationships: relationships)
      end
    end
  end
end
