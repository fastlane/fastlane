require 'strscan'

module FastlaneCore
  module Xcode
    # Parses the OpenStep ("old-style ASCII") property list format, which is what Xcode
    # writes to `project.pbxproj`. Only reading is supported: every scalar comes back as a
    # String, dictionaries as Hashes and arrays as Arrays, which is the same shape the
    # Xcodeproj gem produces from `Project#to_hash`.
    class AsciiPlist
      class ParseError < StandardError; end

      UNQUOTED_STRING = %r{[\w$/:.-]+}
      SIMPLE_ESCAPES = {
        'a' => "\a", 'b' => "\b", 'f' => "\f", 'n' => "\n", 'r' => "\r",
        't' => "\t", 'v' => "\v", "\n" => "\n", '\\' => '\\'
      }.freeze

      def self.parse(string)
        new(string).parse
      end

      def initialize(string)
        string = string.dup.force_encoding(Encoding::UTF_8)
        string = string.delete_prefix("﻿") # strip a UTF-8 BOM
        @scanner = StringScanner.new(string)
      end

      def parse
        skip_whitespace_and_comments
        value = read_value
        skip_whitespace_and_comments
        raise error("unexpected content after the end of the property list") unless @scanner.eos?
        value
      end

      private

      def read_value
        skip_whitespace_and_comments
        case @scanner.peek(1)
        when '{' then read_dictionary
        when '(' then read_array
        when '<' then read_data
        when '"', "'" then read_quoted_string
        when '' then raise error("unexpected end of input")
        else read_unquoted_string
        end
      end

      def read_dictionary
        @scanner.getch # {
        hash = {}
        loop do
          skip_whitespace_and_comments
          break if @scanner.skip(/\}/)
          raise error("unterminated dictionary") if @scanner.eos?

          key = read_string
          skip_whitespace_and_comments
          raise error("expected '=' after the dictionary key #{key.inspect}") unless @scanner.skip(/=/)
          value = read_value
          skip_whitespace_and_comments
          raise error("expected ';' after the value for #{key.inspect}") unless @scanner.skip(/;/)
          hash[key] = value
        end
        hash
      end

      def read_array
        @scanner.getch # (
        array = []
        loop do
          skip_whitespace_and_comments
          break if @scanner.skip(/\)/)
          raise error("unterminated array") if @scanner.eos?

          array << read_value
          skip_whitespace_and_comments
          next if @scanner.skip(/,/)
          break if @scanner.skip(/\)/)
          raise error("expected ',' or ')' in array")
        end
        array
      end

      def read_data
        @scanner.getch # <
        hex = @scanner.scan(/[\h\s]*>/)
        raise error("unterminated data") unless hex
        [hex.delete("\s>")].pack('H*')
      end

      def read_string
        skip_whitespace_and_comments
        if @scanner.match?(/["']/)
          read_quoted_string
        else
          read_unquoted_string
        end
      end

      def read_unquoted_string
        string = @scanner.scan(UNQUOTED_STRING)
        raise error("unexpected character #{@scanner.peek(1).inspect}") unless string
        string
      end

      def read_quoted_string
        quote = @scanner.getch
        raw = @scanner.scan(/(?:\\.|[^\\#{quote}])*/m)
        raise error("unterminated string") unless @scanner.skip(/#{quote}/)
        unescape(raw)
      end

      # Mirrors `getSlashedChar()` from Apple's CFOldStylePList.c
      def unescape(string)
        return string unless string.include?('\\')

        result = +''
        index = 0
        while index < string.length
          char = string[index]
          unless char == '\\'
            result << char
            index += 1
            next
          end

          index += 1
          escaped = string[index]
          case escaped
          when nil
            result << '\\'
          when 'a', 'b', 'f', 'n', 'r', 't', 'v', "\n", '\\'
            result << SIMPLE_ESCAPES[escaped]
            index += 1
          when 'U'
            hex = string[index + 1, 4]
            raise error("invalid \\U escape sequence") unless hex =~ /\A\h{4}\z/
            result << [hex.to_i(16)].pack('U')
            index += 5
          when '0'..'7'
            octal = string[index, 3]
            if octal =~ /\A[0-7]{3}\z/
              result << [octal.to_i(8)].pack('U')
              index += 3
            else
              result << escaped
              index += 1
            end
          else
            result << escaped
            index += 1
          end
        end
        result
      end

      def skip_whitespace_and_comments
        loop do
          next if @scanner.skip(/\s+/)
          next if @scanner.skip(%r{//[^\n]*})
          if @scanner.skip(%r{/\*})
            raise error("unterminated comment") unless @scanner.skip_until(%r{\*/})
            next
          end
          break
        end
      end

      def error(message)
        consumed = @scanner.string[0, @scanner.pos]
        line = consumed.count("\n") + 1
        column = consumed.length - (consumed.rindex("\n") || -1)
        ParseError.new("#{message} (line #{line}, column #{column})")
      end
    end
  end
end
