require 'zip'
require 'plist'

module IosDeployKit
  class IpaUploaderError < StandardError 
  end

  # This class takes care of preparing and uploading the given ipa file
  # Metadata + IPA file can not be handled in one file
  class IpaUploader < AppMetadata

    # TODO
    # @param dir The path to the IPA file which should be uploaded
    def initialize(app, dir, ipa_path)
      raise IpaUploaderError.new("IPA on path '#{ipa_path}' not found") unless File.exists?(ipa_path)
      raise IpaUploaderError.new("IPA on path '#{ipa_path}' is not a valid IPA file") unless ipa_path.include?".ipa"

      super(app, dir, false)

      @ipa_file = IosDeployKit::MetadataItem.new(ipa_path)

      build_document
    end

    def transporter
      @transporter ||= ItunesTransporter.new
    end


    def fetch_app_identifier
      plist = fetch_info_plist_file
      return plist['CFBundleIdentifier'] if plist
      return nil
    end

    def fetch_app_version
      plist = fetch_info_plist_file
      return plist['CFBundleShortVersionString'] if plist
      return nil
    end


    #####################################################
    # @!group Uploading the ipa file # TODO: pragma mark
    #####################################################

    # Actually upload the updated metadata to Apple
    def upload!
      # First: Write the current XML state to disk
      folder_name = "#{@app.apple_id}.itmsp"
      path = "#{self.metadata_dir}/#{folder_name}/"
      FileUtils.mkdir_p path

      File.write("#{path}/#{METADATA_FILE_NAME}", @data.to_xml)

      @ipa_file.store_file_inside_package(path)

      transporter.upload(@app, self.metadata_dir)
    end

    

    private
      def build_document
        builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.package(xmlns: "http://apple.com/itunes/importer", version: "software4.7") {
            xml.software_assets(apple_id: @app.apple_id) {
              xml.asset(type: 'bundle') {

              }
            }
          }
        end

        @data = builder.doc
        asset = @data.xpath('//x:asset', "x" => IosDeployKit::AppMetadata::ITUNES_NAMESPACE).first
        asset << @ipa_file.create_xml_node(@data)
      end

      def fetch_info_plist_file
        Zip::File.open(@ipa_file.path) do |zipfile|
          zipfile.each do |file|
            if file.name.include?'Info.plist' # TODO: how can we find the actual name of the plist file?

              # The XML file has to be properly unpacked first
              tmp_path = "/tmp/deploytmp.plist"
              File.write(tmp_path, zipfile.read(file))
              system("plutil -convert xml1 #{tmp_path}")
              result = Plist::parse_xml(tmp_path)
              File.delete(tmp_path)

              return result
            end
          end
        end

        nil
      end

  end
end