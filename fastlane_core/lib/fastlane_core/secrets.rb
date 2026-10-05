require_relative 'core_ext/shellwords'
require_relative 'env'

module FastlaneCore
  # Values hidden from everything fastlane prints. Only output is masked: commands still receive the real value.
  # FASTLANE_DISABLE_SECRET_MASKING turns it off, for debugging.
  module Secrets
    MASK = '********'.freeze
    # Shorter values would mask unrelated text.
    MIN_LENGTH = 4

    # Masks what is written to an IO, so `puts`, `print`, `abort` and Logger output are covered.
    module OutputFilter
      def write(*args)
        super(*args.map { |arg| Secrets.mask(arg.to_s) })
      end
    end

    class << self
      # Registers a secret, or every String inside a Hash or Array, together with the escaped forms `sh` prints.
      def register(value)
        case value
        when Hash then value.each_value { |v| register(v) }
        when Array then value.each { |v| register(v) }
        when String
          return if value.length < MIN_LENGTH

          [value, Shellwords.escape(value), value.shellescape].each { |form| values << form.b unless values.include?(form.b) }
          values.sort_by! { |v| -v.length }
          install_output_filter unless disabled?
        end
      end

      def mask(text)
        return text if values.empty? || !text.kind_of?(String) || disabled?

        masked = text.b
        values.each { |v| masked.gsub!(v, MASK) }
        masked.force_encoding(text.encoding)
      end

      def values
        @values ||= []
      end

      def clear
        @values = []
      end

      def disabled?
        FastlaneCore::Env.truthy?('FASTLANE_DISABLE_SECRET_MASKING')
      end

      private

      def install_output_filter
        [$stdout, $stderr].each do |io|
          io.singleton_class.prepend(OutputFilter) unless io.singleton_class.include?(OutputFilter)
        end
      end
    end
  end
end
