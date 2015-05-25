module Spaceship
  class Base
    class << self
      attr_accessor :client

      def client
        @client || Spaceship.client
      end

      #set client and return self for chaining
      def set_client(client)
        self.client = client
        self
      end

      ##
      # bang method since it changes the parameter in-place
      def remap_keys!(attrs)
        return if attr_mapping.nil?

        @attr_mapping.each do |from, to|
          attrs[to] = attrs.delete(from)
        end
      end

      def attr_mapping(attrs = nil)
        if attrs
          @attr_mapping = attrs
        else
          @attr_mapping ||= ancestors[1].attr_mapping rescue nil
        end
      end

      ##
      # are we trying to get a subclass?
      # if the method matches a underscored version
      # return the class with the current client passed into it.
      def method_missing(method_sym, *args, &block)
        module_name = method_sym.to_s
        module_name.sub!(/^[a-z\d]/) { $&.upcase }
        module_name.gsub!(/(?:_|(\/))([a-z\d])/) { $2.upcase }
        const_name = "#{self.name}::#{module_name}"
        if const_defined?(const_name)
          klass = const_get(const_name)
          klass.set_client(@client)
        else
          super
        end
      end
    end

    def initialize(attrs = {})
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
