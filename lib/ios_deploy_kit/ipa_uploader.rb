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
      return 'not yet done'
    end

    def fetch_app_version
      return 'not yet done'
    end


    #####################################################
    # Uploading the ipa file # TODO: pragma mark
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

  end
end