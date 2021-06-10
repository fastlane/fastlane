module Spaceship
  module Portal
    class JSONApiBase

      attr_accessor :type, :id, :attributes, :relationships, :data

      def initialize(type: nil, id: nil, attributes: nil, relationships: nil, data: nil)
        @type = type
        @id = id
        @attributes = attributes
        @relationships = relationships
        @data = data
      end

      # Converts self to a JSON:API-formatted hash object.
      def to_hash
        hash = {}
        self.instance_variables.each {|var|
          if self.instance_variable_get(var) != nil
            hash[var.to_s.delete("@")] = self.instance_variable_get(var) 
          end
        }
        return hash
      end

      # Takes in an object (defaults to self) and deeply converts it into a JSON:API-formatted hash object that can be used for requests.
      def to_hash_deep(obj = self)
        result = {}
        if obj.is_a? Spaceship::Portal::JSONApiBase
          hash = obj.to_hash
          hash.each {|key, val|
            result[key] = to_hash_deep(val)
          }
        elsif obj.is_a? Hash
          obj.each {|key, val|
            result[key] = to_hash_deep(val)
          }
        elsif obj.is_a? Array
          result = []
          obj.each{|val|
            result.push(to_hash_deep(val))
          }
        else
          return obj
        end
        return result
      end
    end

    # Top level object that holds the data for an update bundle request.
    class UpdateBundleRequest < JSONApiBase
      def initialize(app, service)
        data = UpdateBundleRequestContents.new(app, service)
        super(data: data)
      end
    end

    class UpdateBundleRequestContents < JSONApiBase

      def initialize(app, service)
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
          bundleIdCapabilities: JSONApiBase.new(data: [BundleIdCapability.new(service)])
        }
        super(type: "bundleIds", id: app.app_id, attributes: attributes, relationships: relationships)
      end
    end

    class BundleIdCapability < JSONApiBase

      def initialize(service)
        attributes = {
          enabled: service.value,
          settings:service.capability_settings
        }
        relationships = {
          capability: JSONApiBase.new(data: JSONApiBase.new(type: "capabilities", id: service.service_id))
        }
        super(type: "bundleIdCapabilities", attributes: attributes, relationships: relationships)
      end
    end
  end
end
