module Spaceship
  ##
  # Spaceship::Base is the superclass for models in Apple Developer Portal.
  # It's mainly responsible for mapping responses to objects.
  #
  # A class-level attribute `client` is used to maintain the which spaceship we
  # are using to talk to ADP.
  #
  # Example of creating a new ADP model:
  #
  #   class Widget < Spaceship::Base
  #     attr_accessor :id, :name, :foo_bar, :wiz_baz
  #     attr_mapping({
  #       'name' => :name,
  #       'fooBar' => :foo_bar,
  #       'wizBaz' => :wiz_baz
  #     })
  #   end
  #
  # When you want to instantiate a model pass in the parsed response: `Widget.new(widget_json)`
  class Base
    class << self
      attr_accessor :client

      ##
      # The client used to make requests.
      # @return (Spaceship::Client) Defaults to the singleton `Spaceship.client`
      def client
        @client || Spaceship.client
      end

      ##
      # Sets client and returns self for chaining.
      # @return (Spaceship::Base)
      def set_client(client)
        self.client = client
        self
      end

      ##
      # Remaps the attributes passed into the initializer to the model
      # attributes using the map defined by `attr_map`.
      #
      # This method consumes the input parameter meaning attributes that were
      # remapped are deleted.
      #
      # @return (Hash) the attribute mapping used by `remap_keys!`
      def remap_keys!(attrs)
        return if attr_mapping.nil?

        attr_mapping.each do |from, to|
          attrs[to] = attrs.delete(from)
        end
      end

      ##
      # Defines the attribute mapping between the response from Apple and our model objects.
      # Keys are to match keys in the response and the values are to match attributes on the model.
      #
      # Example of using `attr_mapping`
      #
      #   class Widget < Spaceship::Base
      #     attr_accessor :id, :name, :foo_bar, :wiz_baz
      #     attr_mapping({
      #       'name' => :name,
      #       'fooBar' => :foo_bar,
      #       'wizBaz' => :wiz_baz
      #     })
      #   end
      def attr_mapping(attr_map = nil)
        if attr_map
          @attr_mapping = attr_map
        else
          begin
            @attr_mapping ||= ancestors[1].attr_mapping 
          rescue NameError, NoMethodError
          end
        end
      end

      ##
      # Call a method to return a subclass constant.
      #
      # If `method_sym` is an underscored name of a class,
      # return the class with the current client passed into it.
      # If the method does not match, NoMethodError is raised.
      #
      # Example:
      #
      #   Certificate.production_push
      #   #=> Certificate::ProductionPush
      #
      #   ProvisioningProfile.ad_hoc
      #   #=> ProvisioningProfile::AdHoc
      #
      #   ProvisioningProfile.some_other_method
      #   #=> NoMethodError: undefined method `some_other_method' for ProvisioningProfile
      def method_missing(method_sym, *args, &block)
        module_name = method_sym.to_s
        module_name.sub!(/^[a-z\d]/) { $&.upcase }
        module_name.gsub!(/(?:_|(\/))([a-z\d])/) { $2.upcase }
        if const_defined?(module_name)
          klass = const_get(module_name)
          klass.set_client(@client)
        else
          super
        end
      end
    end

    ##
    # The initialize method accepts a parsed response from Apple and sets all
    # attributes that are defined by `attr_mapping`
    #
    # Do not override `initialize` in your own models.
    def initialize(attrs = {})
      self.class.remap_keys!(attrs)
      attrs.each do |key, val|
        self.send("#{key}=", val) if respond_to?("#{key}=")
      end
      @client = self.class.client
    end

    ##
    # @return (Spaceship::Client) The current spaceship client used by the model to make requests.
    def client
      @client
    end

    def inspect
      inspectables = instance_variables - [:@client]
      inspect_vars = inspectables.map do |ivar|
         val = instance_variable_get(ivar)
         "#{ivar}=#{val.inspect}"
      end
      "\n#<#{self.class.name}\n\t#{inspect_vars.join("\n\t")}>"
    end
  end
end
