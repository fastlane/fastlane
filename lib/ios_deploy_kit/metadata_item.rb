require 'nokogiri'

module IosDeployKit
  class MetadataItem
    # This class represents a file, included in the metadata.xml
    # It takes care of calculating the file size and md5 value

    attr_accessor :path, :custom_node_name


    def initialize(path, custom_node_name = nil)
      raise "File not found at path '#{path}'" unless File.exists?path

      self.path = path
      self.custom_node_name = custom_node_name
    end

    # This method is called when storing this item into the metadata.xml file
    def create_xml_node(doc)
      # Generates XML code that looks something like this

      # <data_file>
      #     <size>11463227</size>
      #     <file_name>myapp.54.56.ipa</file_name>
      #     <checksum type="md5">9d6b7b0e20bde9a3c831db89563e949f</checksum>
      # </data_file>

      # Take a look at the subclass AppScreenshot for screenshot specific code

      screenshot = Nokogiri::XML::Node.new(self.name_for_xml_node, doc)

      node_set = Nokogiri::XML::NodeSet.new(doc)
      
      # File Size
      size = Nokogiri::XML::Node.new('size', doc)
      size.content = File.size(self.path)
      node_set << size

      # File Name
      file_name = Nokogiri::XML::Node.new('file_name', doc)
      file_name.content = path.split("/").last
      node_set << file_name

      # md5 Checksum
      checksum = Nokogiri::XML::Node.new('checksum', doc)
      checksum.content = Digest::MD5.hexdigest(File.read(path))
      checksum['type'] = 'md5'
      node_set << checksum


      screenshot.children = node_set
      return screenshot
    end

    def store_file_inside_package(path_to_package)
      # We also have to copy the file itself, since it has to be **inside** the package
      FileUtils.cp(self.path, path_to_package)
    end

    def name_for_xml_node
      custom_node_name || 'data_file'
    end
  end
end