module Spaceship
  class Base
    class << self

      def client
        @@client ||= Spaceship.client
      end

      def client=(client)
        @@client = client
      end

      ##
      # bang method since it changes the parameter in-place
      def remap_keys!(attrs)
        return if @attr_mapping.nil?

        @attr_mapping.each do |from, to|
          attrs[to] = attrs.delete(from)
        end
      end

      def attr_mapping(attrs)
        @attr_mapping = attrs
      end
    end

    def initialize(attrs)
      self.class.remap_keys!(attrs)
      attrs.each do |key, val|
        self.send("#{key}=", val) if respond_to?("#{key}=")
      end
      @client = self.class.client
    end

    def client
      @client
    end

    def inspect
      inspectables = instance_variables - [:@client]
      inspect_vars = inspectables.map do |ivar|
         val = instance_variable_get(ivar)
         "#{ivar}=#{val.inspect}"
      end
      "#<#{self.class.name} #{inspect_vars.join(', ')}>"
    end

  end
end