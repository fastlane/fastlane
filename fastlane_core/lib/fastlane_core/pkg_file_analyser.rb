require 'rexml/document'

require_relative 'helper'

module FastlaneCore
  class PkgFileAnalyser
    def self.fetch_app_identifier(path)
      xml = self.fetch_distribution_xml_file(path)
      if xml
        return xml.elements['installer-gui-script/product'].attributes['id']
      end
      return nil
    end

    # Fetches the app version from the given pkg file.
    def self.fetch_app_version(path)
      xml = self.fetch_distribution_xml_file(path)
      if xml
        return xml.elements['installer-gui-script/product'].attributes[
          'version'
        ]
      end
      return nil
    end

    def self.fetch_distribution_xml_file(path)
      Dir.mktmpdir do |dir|
        Helper.backticks("xar -C #{dir.shellescape} -xf #{path.shellescape}")

        Dir.foreach(dir) do |file|
          next unless file.include?('Distribution')

          begin
            content = File.open(File.join(dir, file))
            xml = REXML::Document.new(content)

            return xml if xml.elements['installer-gui-script/product']
          rescue => ex
            UI.error(ex)
            UI.error(
              "Error parsing *.pkg distribution xml #{File.join(dir, file)}"
            )
          end
        end

        nil
      end
    end
  end
end
