require 'cfpropertylist'
require 'plist'
require_relative 'error'
require_relative 'ascii_plist'

module FastlaneCore
  module Xcode
    # Reads property lists in any of the three formats Xcode produces (XML, binary and
    # old-style ASCII) and writes them back as XML.
    module Plist
      def self.read_from_path(path)
        path = path.to_s
        raise Error, "The plist file at path `#{path}` doesn't exist." unless File.exist?(path)

        contents = File.binread(path)
        raise Error, "The file `#{path}` is in a merge conflict." if file_in_conflict?(contents)

        case contents
        when /\Abplist/, /\A<\?xml/
          CFPropertyList.native_types(CFPropertyList::List.new(data: contents).value)
        else
          AsciiPlist.parse(contents)
        end
      end

      def self.write_to_path(hash, path)
        raise TypeError, "The given `#{hash.inspect}` must respond to #to_hash" unless hash.respond_to?(:to_hash)
        File.write(path.to_s, ::Plist::Emit.dump(hash.to_hash))
      end

      def self.file_in_conflict?(contents)
        contents.match?(/^<{7}(?!<)[\w\W]*^={7}(?!=)[\w\W]*^>{7}(?!>)/m)
      end
    end
  end
end
