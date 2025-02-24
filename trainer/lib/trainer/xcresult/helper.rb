require 'rexml/document'

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
        element = REXML::Element.new(name)
        attributes.compact.each { |key, value| element.attributes[key.to_s] = value.to_s }
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
    end
  end
end
