require 'rexml/document'
require 'rubygems'

module Trainer
  module XCResult
    # Helper class for XML and node operations
    class Helper
      # Creates an XML element with the given name and attributes
      #
      # @param name [String] The name of the XML element
      # @param attributes [Hash] A hash of attributes to add to the element
      # @return [REXML::Element] The created XML element
      def self.create_xml_element(name, **attributes)
        # Sanitize invalid XML characters (control chars except tab/CR/LF) to avoid errors when generating XML
        sanitizer = proc { |text| text.to_s.gsub(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/) { |c| format("\\u%04x", c.ord) } }
        element = REXML::Element.new(sanitizer.call(name))
        attributes.compact.each do |key, value|
          safe_value = sanitizer.call(value.to_s)
          element.attributes[key.to_s] = safe_value
        end
        element
      end

      # Find children of a node by specified node types
      #
      # @param node [Hash, nil] The JSON node to search within
      # @param node_types [Array<String>] The node types to filter by
      # @return [Array<Hash>] Array of child nodes matching the specified types
      def self.find_json_children(node, *node_types)
        return [] if node.nil? || node['children'].nil?

        node['children'].select { |child| node_types.include?(child['nodeType']) }
      end

      # Check if the current xcresulttool supports new commands introduced in Xcode 16+
      #
      # Since Xcode 16b3, xcresulttool has marked `get <object> --format json` as deprecated/legacy,
      # and replaced it with `xcrun xcresulttool get test-results tests` instead.
      #
      # @return [Boolean] Whether the xcresulttool supports Xcode 16+ commands
      def self.supports_xcode16_xcresulttool?
        # e.g. DEVELOPER_DIR=/Applications/Xcode_16_beta_3.app
        # xcresulttool version 23021, format version 3.53 (current)
        match = `xcrun xcresulttool version`.match(/xcresulttool version (?<version>[\d.]+)/)
        version = match[:version]

        Gem::Version.new(version) >= Gem::Version.new(23_021)
      rescue
        false
      end
    end
  end
end
