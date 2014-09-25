require 'nokogiri'

module IosDeployKit
  class AppMetadataError < StandardError 
  end
  class AppMetadataParameterError < StandardError 
  end

  class AppMetadata
    ITUNES_NAMESPACE = "http://apple.com/itunes/importer"

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
      update_localized_value('description', hash) do |field, new_val|
        raise AppMetadataParameterError.new("Parameter needs to be an hash, containg strings with the new description") unless new_val.kind_of?String

        field.content = new_val
      end
    end

    # Update the app keywords
    def update_keywords(hash)
      update_localized_value('keywords', hash) do |field, keywords|
        raise AppMetadataParameterError.new("Parameter needs to be a hash (each language) with an array of keywords in it") unless keywords.kind_of?Array

        field.children.remove # remove old keywords

        node_set = Nokogiri::XML::NodeSet.new(@data)
        keywords.each do |word|
          keyword = Nokogiri::XML::Node.new('keyword', @data)
          keyword.content = word
          node_set << keyword
        end

        field.children = node_set
      end
    end

    # Usage: '//x:keyword'
    def fetch_value(xpath)
      @data.xpath(xpath, "x" => ITUNES_NAMESPACE)
    end


    #####################################################
    # Uploading the updated metadata
    #####################################################

    # Actually upload the updated metadata to Apple
    def upload!
      transporter.upload(@app, @app.get_metadata_directory)
    end

    private

      def update_localized_value(xpath_name, new_value)
        raise AppMetadataParameterError.new("Please pass a hash of languages to this method") unless new_value.kind_of?Hash
        raise AppMetadataParameterError.new("Please pass a block, which updates the resulting node") unless block_given?

        fetch_value("//x:locale").each do |locale|
          key = locale['name']
          if new_value[key]
            field = locale.search(xpath_name).first
            if field.content != new_value[key]
              yield(field, new_value[key])
              Helper.log.info "Updated #{xpath_name} for locale #{key}"
            else
              Helper.log.info "Did not update #{xpath_name} for locale #{locale}, since it hasn't changed"
            end
          else
            Helper.log.error "Could not find '#{xpath_name}' for #{key}. It was provided before. Not updating this value"
          end
        end
      end

      # Parses the metadata using nokogiri
      def parse_package(path)        
        @data ||= Nokogiri::XML(File.read("#{path}/#{@app.apple_id}.itmsp/metadata.xml"))
        verify_package
        clean_package
      end

      # Checks if there is a non live version available
      # (a new version, or a new app)
      def verify_package
        versions = fetch_value("//x:version")

        # TODO: This does not work for new apps
        raise AppMetadataError.new("You have to create a new version before modifying the app metadata") if versions.count == 1

        raise AppMetadataError.new("metadata_token is missing") if fetch_value("//x:metadata_token").count != 1
      end

      # Cleans up the package of stuff we do not want to modify/upload
      def clean_package


        # Remove the live version (if it exists)
        versions = fetch_value("//x:version")
        while versions.count > 1
          versions.last.remove
          versions = fetch_value("//x:version")
        end
        Helper.log.info "Modifying version '#{versions.first.attr('string')}' of app #{@app.app_identifier}"


      end
  end
end