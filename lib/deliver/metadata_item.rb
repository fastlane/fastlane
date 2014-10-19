require 'nokogiri'

module Deliver
  # This class represents a file, included in the metadata.xml
  # 
  # It takes care of calculating the file size and md5 value.
  class MetadataItem
    # @return [String] The path to this particular asset
    attr_accessor :path

    # Returns a new instance of MetadataItem
    # @param path [String] the path to the real world file
    # @param custom_node_name [String] You can set a custom name
    #  for the newly created node.
    def initialize(path, custom_node_name = nil)
      raise "File not found at path '#{path}'" unless File.exists?path

      self.path = path
      @custom_node_name = custom_node_name
    end

    # This method is called when storing this item into the metadata.xml file
    # 
    # This method will calculate the md5 hash and exact file size
    # Generates XML code that looks something like this
    # +code+
    #   <data_file>
    #     <size>11463227</size>
    #     <file_name>myapp.54.56.ipa</file_name>
    #     <checksum type="md5">9d6b7b0e20bde9a3c831db89563e949f</checksum>
    #   </data_file>
    # Take a look at the subclass {Deliver::AppScreenshot#create_xml_node} for a
    # screenshot specific implementation
    # @param doc [Nokogiri::XML::Document] The document this node
    #  should be added to
    # @return [Nokogiri::XML::Node] the resulting XML node
    def create_xml_node(doc)
      screenshot = Nokogiri::XML::Node.new(name_for_xml_node, doc)

      node_set = Nokogiri::XML::NodeSet.new(doc)
      
      # File Size
      size = Nokogiri::XML::Node.new('size', doc)
      size.content = File.size(self.path)
      node_set << size

      # File Name
      file_name = Nokogiri::XML::Node.new('file_name', doc)
      file_name.content = resulting_file_name
      node_set << file_name

      # md5 Checksum
      checksum = Nokogiri::XML::Node.new('checksum', doc)
      checksum.content = md5_value
      checksum['type'] = 'md5'
      node_set << checksum


      screenshot.children = node_set

      return screenshot
    end

    # We also have to copy the file itself, since it has to be *inside* the package
    # You don't have to call this method manually.
    def store_file_inside_package(path_to_package)
      # This will also rename the resulting file to not have any spaces or other
      # illegal characters in the file name
      
      FileUtils.cp(self.path, "#{path_to_package}/#{resulting_file_name}")
    end

    private
      def name_for_xml_node
        @custom_node_name || 'data_file'
      end

      # The file name which is used inside the package
      def resulting_file_name
        extension = File.extname(self.path)
        "#{file_name_for_element}#{extension}"
      end

      def md5_value
        Digest::MD5.hexdigest(File.read(self.path))
      end

      # This method will also take some other things into account to generate a truly unique
      # file name. This will enable using the same screenshots multiple times
      def file_name_for_element
        Digest::MD5.hexdigest([File.read(self.path), self.path].join("-"))
      end
  end
end