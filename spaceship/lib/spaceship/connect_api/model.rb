module Spaceship
  class ConnectAPI
    module Model
      def self.included(base)
        Spaceship::ConnectAPI::Models.types ||= []
        Spaceship::ConnectAPI::Models.types << base
        base.extend(Spaceship::ConnectAPI::Model)
      end

      attr_accessor :id

      def initialize(id, attributes)
        self.id = id
        update_attributes(attributes)
      end

      def update_attributes(attributes)
        attributes.each do |key, value|
          method = "#{key}=".to_sym
          self.send(method, value) if self.respond_to?(method)
        end
      end

      #
      # Example:
      # { "minOsVersion" => "min_os_version" }
      #
      # Creates attr_write and attr_reader for :min_os_version
      # Creates alias for :minOsVersion to :min_os_version
      #
      def attr_mapping(attr_map)
        attr_map.each do |key, value|
          # Actual
          reader = value.to_sym
          writer = "#{value}=".to_sym

          has_reader = instance_methods.include?(reader)
          has_writer = instance_methods.include?(writer)

          send(:attr_reader, value) unless has_reader
          send(:attr_writer, value) unless has_writer

          # Alias
          key_reader = key.to_sym
          key_writer = "#{key}=".to_sym

          # Alias the API response name to attribute name
          alias_method(key_reader, reader)
          alias_method(key_writer, writer)
        end
      end
    end

    module Models
      class << self
        attr_accessor :types
        attr_accessor :types_cache
      end

      def self.parse(json)
        data = json["data"]
        raise "No data" unless data

        included = json["included"] || []

        if data.kind_of?(Hash)
          inflate_model(data, included)
        elsif data.kind_of?(Array)
          return data.map do |model_data|
            inflate_model(model_data, included)
          end
        else
          raise "'data' is neither a hash nor an array"
        end
      end

      def self.find_class(model_data)
        # Initialize cache
        @types_cache ||= {}

        # Find class in cache
        type_string = model_data["type"]
        type_class = @types_cache[type_string]
        return type_class if type_class

        # Find class in array
        type_class = @types.find do |type|
          type.type == type_string
        end

        # Cache and return class
        @types_cache[type_string] = type_class
        return type_class
      end

      def self.inflate_model(model_data, included)
        # Find class
        type_class = find_class(model_data)
        raise "No type class found for #{model_data['type']}" unless type_class

        # Get id and attributes needed for inflating
        id = model_data["id"]
        attributes = model_data["attributes"]

        # Instantiate object and inflate relationships
        relationships = model_data["relationships"] || []
        type_instance = type_class.new(id, attributes)
        type_instance = inflate_model_relationships(type_instance, relationships, included)

        return type_instance
      end

      def self.inflate_model_relationships(type_instance, relationships, included)
        # Relationship attributes to set
        attributes = {}

        # 1. Iterate over relationships
        # 2. Find id and type
        # 3. Find matching id and type in included
        # 4. Inflate matching data and set in attributes
        relationships.each do |key, value|
          # Validate data exists
          value_data_or_datas = value["data"]
          next unless value_data_or_datas

          # Map an included data object
          map_data = lambda do |value_data|
            id = value_data["id"]
            type = value_data["type"]

            relationship_data = included.find do |included_data|
              id == included_data["id"] && type == included_data["type"]
            end

            inflate_model(relationship_data, included)
          end

          # Map a hash or an array of data
          if value_data_or_datas.kind_of?(Hash)
            attributes[key] = map_data.call(value_data_or_datas)
          elsif value_data_or_datas.kind_of?(Array)
            attributes[key] = value_data_or_datas.map(&map_data)
          end
        end

        type_instance.update_attributes(attributes)

        return type_instance
      end
    end
  end
end
