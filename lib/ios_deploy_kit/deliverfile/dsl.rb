# Inspired by https://github.com/CocoaPods/Core/blob/master/lib/cocoapods-core/podfile/dsl.rb

module IosDeployKit
  module Deliverfile
    class Deliverfile
      module DSL
        MISSING_VALUE_ERROR_MESSAGE = "You have to pass either a value or a block to the given method."

        MISSING_APP_IDENTIFIER_MESSAGE = "You have to pass a valid app identifier using the Deliver file."
        MISSING_VERSION_NUMBER_MESSAGE = "You have to pass a valid version number using the Deliver file."

        class DeliverfileDSLError < StandardError
        end
        
        # Required to implement

        def version(value = nil)
          value ||= yield if block_given?
          raise DeliverfileDSLError.new(MISSING_VALUE_ERROR_MESSAGE) unless value
          raise DeliverfileDSLError.new("The app version should be a string") unless value.kind_of?(String)
          
          @deliver_data.set_new_value(Deliverer::ValKey::APP_VERSION, value)
        end

        def app_identifier(value = nil)
          value ||= yield if block_given?
          raise DeliverfileDSLError.new(MISSING_VALUE_ERROR_MESSAGE) unless value
          
          @deliver_data.set_app_identifier(value)
        end

        # Optional


        # Error handling
        
        def method_missing(method_sym, *arguments, &block)
          Helper.log.error("Could not find method #{method_sym}!")
        end
      end
    end
  end
end