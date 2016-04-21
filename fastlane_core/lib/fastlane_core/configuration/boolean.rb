module FastlaneCore
  class Boolean
    def self.convert(value)
      klass = value.class
      case
      when klass == TrueClass || klass == FalseClass
        return value
      when klass == String
        if %w(YES yes true TRUE).include?(value)
          return true
        elsif %w(NO no false FALSE).include?(value)
          return false
        end
        # FIXME: remove this ?
        raise "Unexpected String value #{value} for Boolean"
      end
      return value
    end
  end
end

Boolean = FastlaneCore::Boolean
