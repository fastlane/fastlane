require 'json'

module Fastlane
  class JSONReturnValueProcessor
    def prepare_object(return_value: nil, return_value_type: nil)
      case return_value_type
      when nil
        UI.verbose("return_value_type is nil value: #{return_value}")
        return process_value_as_string(return_value: return_value)
      when :string
        return process_value_as_string(return_value: return_value)
      when :int
        return process_value_as_int(return_value: return_value)
      when :bool
        return process_value_as_bool(return_value: return_value)
      when :array_of_strings
        return process_value_as_array_of_strings(return_value: return_value)
      when :hash_of_strings
        return process_value_as_hash_of_strings(return_value: return_value)
      else
        UI.verbose("Unknown return type defined: #{return_value_type} for value: #{return_value}")
        return process_value_as_string(return_value: return_value)
      end
    end

    def process_value_as_string(return_value: nil)
      if return_value.nil?
        return_value = ""
      end

      # quirks_mode because sometimes the built-in library is used for some folks and that needs quirks_mode: true
      return JSON.generate(return_value.to_s, quirks_mode: true)
    end

    def process_value_as_array_of_strings(return_value: nil)
      if return_value.nil?
        return_value = []
      end

      # quirks_mode shouldn't be required for real objects
      return JSON.generate(return_value)
    end

    def process_value_as_hash_of_strings(return_value: nil)
      if return_value.nil?
        return_value = {}
      end

      # quirks_mode shouldn't be required for real objects
      return JSON.generate(return_value)
    end

    def process_value_as_bool(return_value: nil)
      if return_value.nil?
        return_value = false
      end

      # quirks_mode because sometimes the built-in library is used for some folks and that needs quirks_mode: true
      return JSON.generate(return_value.to_s, quirks_mode: true)
    end

    def process_value_as_int(return_value: nil)
      if return_value.nil?
        return_value = 0
      end

      # quirks_mode because sometimes the built-in library is used for some folks and that needs quirks_mode: true
      return JSON.generate(return_value.to_s, quirks_mode: true)
    end
  end
end
