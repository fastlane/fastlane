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
      # A name, such as the option's key, replaces it with `<NAME>_REDACTED` rather than MASK.
      def register(value, name: nil)
        case value
        when Hash then value.each_value { |v| register(v, name: name) }
        when Array then value.each { |v| register(v, name: name) }
        when String
          return if value.length < MIN_LENGTH

          replacement = name ? label(name) : MASK
          [value, Shellwords.escape(value), value.shellescape].each do |form|
            labels[form.b] = replacement if [nil, MASK].include?(labels[form.b])
          end
          @pattern = nil
          install_output_filter unless disabled?
        end
      end

      def mask(text)
        return text if labels.empty? || !text.kind_of?(String) || disabled?

        # One pass: a name put in place of a secret is not masked again by a shorter secret it contains
        text.b.gsub(pattern) { |match| labels[match] }.force_encoding(text.encoding)
      end

      # What a secret registered under this name is replaced with, e.g. API_TOKEN_REDACTED
      def label(name)
        "#{name.to_s.upcase}_REDACTED"
      end

      def labels
        @labels ||= {}
      end

      def clear
        @labels = {}
        @pattern = nil
      end

      def disabled?
        FastlaneCore::Env.truthy?('FASTLANE_DISABLE_SECRET_MASKING')
      end

      private

      # Longest first, so a secret wins over a shorter one it contains
      def pattern
        @pattern ||= Regexp.union(labels.keys.sort_by { |v| -v.length })
      end

      def install_output_filter
        [$stdout, $stderr].each do |io|
          io.singleton_class.prepend(OutputFilter) unless io.singleton_class.include?(OutputFilter)
        end
      end
    end
  end
end
