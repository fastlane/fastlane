module Spaceship
  module Tunes
    class TunesBase < Spaceship::Base
      attr_accessor :raw_data

      class << self
        def client
          @client || Spaceship::Tunes.client
        end

        def remap_keys!(attrs)
          return if attr_mapping.nil?

          attr_mapping.each do |from, to|
            if attrs[from].is_a?(Hash)
              attrs[to] = attrs.delete(from).fetch('value')
            else
              attrs[to] = attrs.delete(from) 
            end
          end
        end

        def attr_mapping(attr_map = nil)
          result = super

          (attr_map || []).each do |key,val|
            define_method("#{key}=") do |value|
              # Set the new value in any case
              instance_variable_set("@#{key}".to_sym, value)

              if raw_data
                raw_data[key] ||= {}
                raw_data[key]['value'] = value
              end
            end
          end

          return result
        end
      end
    end
  end
end