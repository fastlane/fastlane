module Spaceship
  module ConnectAPI
    module Model
      def self.included(base)
        Spaceship::ConnectAPI::Models.types ||= []
        Spaceship::ConnectAPI::Models.types << base
        base.extend(Spaceship::ConnectAPI::Model)
      end

      attr_accessor :id

      def initialize(id, attributes)
        self.id = id
        set_attributes(attributes)
      end

      def set_attributes(attributes)
        attributes.each do |key, value|
          method = "#{key}=".to_sym
          self.send(method, value) if self.respond_to?(method)
        end
      end

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

          alias_method key_reader, reader
          alias_method key_writer, writer
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

        if data.is_a?(Hash)
          inflate_model(model_data, included)
        elsif data.is_a?(Array)
          return data.map do |model_data|
            inflate_model(model_data, included)
          end
        else
          puts "something else"
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
        raise "No type class found for #{model_data["type"]}" unless type_class


        id = model_data["id"]
        attributes = model_data["attributes"]

        type_instance = type_class.new(id, attributes)
        type_instance = inflate_model_relationships(type_instance, model_data, included)

        return type_instance
      end

      def self.inflate_model_relationships(type_instance, model_data, included)
        attributes = {}

        relationships = model_data["relationships"] || []
        relationships.each do |key, value|
          value_data = value["data"]
          if value_data
            id = value_data["id"]
            type = value_data["type"]

            relationship_data = included.find do |included_data|
              id == included_data["id"] && type == included_data["type"]
            end

            attributes[key] = inflate_model(relationship_data, included)
          end
        end

        type_instance.set_attributes(attributes)

        return type_instance
      end
    end
  end
end
