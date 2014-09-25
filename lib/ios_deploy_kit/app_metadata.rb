require 'nokogiri'

module IosDeployKit
  class AppMetadata
    APPLE_ITUNES_NAMESPACE = "http://apple.com/itunes/importer"

    attr_accessor :metadata_dir

    def transporter
      @transporter ||= ItunesTransporter.new
    end

    def initialize(app, dir)
      self.metadata_dir = dir
      @app = app

      # we want to update the metadata, so first we have to download the existing one
      transporter.download(app, dir)

      # Parse the downloaded package
      parse_package(dir)
    end


    #####################################################
    # Updating metadata information
    #####################################################

    # Update the app description which is shown in the AppStore
    def update_description(hash)
      raise "Please pass a hash of languages to this method" unless hash.kind_of?Hash

      # TODO: Implement
    end


    #####################################################
    # Uploading the updated metadata
    #####################################################

    # Actually upload the updated metadata to Apple
    def upload!
      transporter.upload(@app, @app.get_metadata_directory)
    end

    private
      def modify_value(xpath, new_value)
        binding.pry

        @data.xpath("//x:#{xpath}", "x" => APPLE_ITUNES_NAMESPACE)
      end

      def parse_package(path)        
        @data ||= Nokogiri::XML(File.read("#{self.metadata_dir}/#{@app.apple_id}.itmsp/metadata.xml"))
      end
  end
end