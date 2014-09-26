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

    def initialize(app, dir, redownload_package = true)
      self.metadata_dir = dir
      @app = app

      if redownload_package
        # we want to update the metadata, so first we have to download the existing one
        transporter.download(app, dir)

        # Parse the downloaded package
        parse_package(dir)
      else
        # use_data contains the data to be used. This is the case for unit tests
        parse_package(dir)
      end
    end


    #####################################################
    # Updating metadata information
    #####################################################

    # Update the app title
    def update_title(hash)
      update_localized_value('title', hash) do |field, new_val|
        raise AppMetadataParameterError.new("Parameter needs to be an hash, containg strings with the new description") unless new_val.kind_of?String
        field.content = new_val
      end
    end

    # Update the app description which is shown in the AppStore
    def update_description(hash)
      update_localized_value('description', hash) do |field, new_val|
        raise AppMetadataParameterError.new("Parameter needs to be an hash, containg strings with the new description") unless new_val.kind_of?String
        field.content = new_val
      end
    end

    # Set the changelog
    def update_changelog(hash)
      update_localized_value('version_whats_new', hash) do |field, new_val|
        raise AppMetadataParameterError.new("Parameter needs to be an hash, containg strings with the new description") unless new_val.kind_of?String
        field.content = new_val
      end
    end

    # Update the Marketing URL
    def update_marketing_url(hash)
      update_localized_value('software_url', hash) do |field, new_val|
        raise AppMetadataParameterError.new("Parameter needs to be an hash, containg strings with the new description") unless new_val.kind_of?String
        field.content = new_val
      end
    end

    # Update the support URL
    def update_support_url(hash)
      update_localized_value('support_url', hash) do |field, new_val|
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

    #####################################################
    # Screenshot related
    #####################################################

    # Removes all currently enabled screenshots for the given language
    def clear_all_screenshots(language)
      update_localized_value('software_screenshots', {language => {}}) do |field, useless, language|
        field.children.remove # remove all the screenshots
      end
    end

    # Appends another screenshot to the already existing ones
    # This will raise an exception, when there are already 5 screenshots
    def add_screenshot(language, app_screenshot)
      
      # Fetch the 'software_screenshots' node (array) for the specific locale
      locales = self.fetch_value("//x:locale[@name='#{language}']")
      raise AppMetadataError.new("Could not find locale entry for #{locale}") unless locales.count == 1

      screenshots = self.fetch_value("//x:locale[@name='#{language}']/x:software_screenshots").first
      
      next_index = screenshots.children.count + 1

      # Ready for storing the screenshot into the metadata.xml now
      screenshots << app_screenshot.create_xml_node(@data, next_index)
    end

    # Using this method will clear all screenshots and set the new ones
    # Pass the hash like this:
    # {
    #   'de-DE' => [
    #     AppScreenshot.new('path', IosDeployKit::ScreenSize::IOS_35),
    #     AppScreenshot.new('path', IosDeployKit::ScreenSize::IOS_40),
    #     AppScreenshot.new('path', IosDeployKit::ScreenSize::IOS_IPAD)
    #   ]
    # }
    # This method uses clear_all_screenshots and add_screenshot under the hood
    def set_all_screenshots(hash)
      error_text = "Please pass a hash, containing an array of AppScreenshot objects"
      raise AppMetadataParameterError.new(error_text) unless hash.kind_of?Hash

      hash.each do |key, value|
        if key.kind_of?String and value.kind_of?Array and value.count > 0 and value.first.kind_of?AppScreenshot
          
          self.clear_all_screenshots(key)

          value.each do |screen|
            add_screenshot(key, screen)
          end
        else
          raise AppMetadataParameterError.new(error_text)
        end
      end
    end


    #####################################################
    # Manually fetching elements from the metadata.xml
    #####################################################

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

        # Run through all the locales given in the metadata.xml
        fetch_value("//x:locale").each do |locale|
          key = locale['name']
          if new_value[key]
            # now search for the given key inside this locale
            field = locale.search(xpath_name).first
            if field.content != new_value[key]
              yield(field, new_value[key], key)
              Helper.log.info "Updated #{xpath_name} for locale #{key}"
            else
              Helper.log.info "Did not update #{xpath_name} for locale #{locale}, since it has not changed"
            end
          else
            Helper.log.error "Could not find '#{xpath_name}' for #{key}. It was provided before. Not updating this value"
          end
        end
      end

      # Parses the metadata using nokogiri
      def parse_package(path)
        @data ||= Nokogiri::XML(File.read("#{path}/metadata.xml"))
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