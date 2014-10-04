# Inspired by https://github.com/CocoaPods/Core/blob/master/lib/cocoapods-core/podfile/dsl.rb

module IosDeployKit
  module Deliverfile
    class Deliverfile
      module DSL
        MISSING_VALUE_ERROR_MESSAGE = "You have to pass either a value or a block to the given method."
        SPECIFY_LANGUAGE_FOR_VALUE = "You have to specify the language of the given value. Either set a default language using 'default_language \"en\"' on the top of the file or pass a hash containing the language codes"

        MISSING_APP_IDENTIFIER_MESSAGE = "You have to pass a valid app identifier using the Deliver file."
        MISSING_VERSION_NUMBER_MESSAGE = "You have to pass a valid version number using the Deliver file."
        INVALID_IPA_FILE_GIVEN = "The given ipa file seems to be wrong. Make sure it's a valid ipa file."

        class DeliverfileDSLError < StandardError
        end
        
        # Setting all the metadata
        def method_missing(method_sym, *arguments, &block)
          allowed = IosDeployKit::Deliverer.all_available_keys_to_set

          if allowed.include?(method_sym)
            value = arguments.first || block.call
            raise DeliverfileDSLError.new(MISSING_VALUE_ERROR_MESSAGE) unless value

            if value.kind_of?String
              # The user should pass a hash for multi-lang values
              # Maybe he at least set a default language
              if @default_language
                value = { @default_language => value }
              else
                raise DeliverfileDSLError.new(SPECIFY_LANGUAGE_FOR_VALUE)
              end
            end

            @deliver_data.set_new_value(method_sym, value)
          else
            Helper.log.error("Could not find method '#{method_sym}'. Available methods: #{allowed.collect { |a| a.to_s }}")
          end
        end

        # This method can be used to set a default language, which is used
        # when passing a string to metadata changes, instead of a hash
        # containing multiple languages
        # TODO: Add example usage
        def default_language(value = nil)
          # TODO: raise error if this method is not on the top of the file
          @default_language = value
          @default_language ||= yield if block_given?
          Helper.log.debug("Set default language to #{@default_language}")
        end

        # Custom actions
        def app_identifier(value = nil)
          value ||= yield if block_given?
          raise DeliverfileDSLError.new(MISSING_VALUE_ERROR_MESSAGE) unless value
          
          @deliver_data.set_app_identifier(value)
        end

        def ipa(value = nil)
          value ||= yield if block_given?
          raise DeliverfileDSLError.new(INVALID_IPA_FILE_GIVEN) unless value
          raise DeliverfileDSLError.new(INVALID_IPA_FILE_GIVEN) unless value.include?".ipa"

          @deliver_data.set_new_value(Deliverer::ValKey::IPA, value)
        end

        # Set the apps new version number
        def version(value = nil)
          value ||= yield if block_given?
          raise DeliverfileDSLError.new(MISSING_VALUE_ERROR_MESSAGE) unless value
          raise DeliverfileDSLError.new("The app version should be a string") unless value.kind_of?(String)
          
          @deliver_data.set_new_value(Deliverer::ValKey::APP_VERSION, value)
        end
        
      end
    end
  end
end