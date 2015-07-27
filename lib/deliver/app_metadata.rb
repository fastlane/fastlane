require 'nokogiri'
require 'deliver/app_metadata_screenshots'

module Deliver
  class AppMetadataError < StandardError
  end
  class AppMetadataParameterError < StandardError
  end
  class AppMetadataTooManyScreenshotsError < StandardError
  end

  class AppMetadata
    ITUNES_NAMESPACE = "http://apple.com/itunes/importer"
    METADATA_FILE_NAME = "metadata.xml"
    MAXIMUM_NUMBER_OF_SCREENSHOTS = 5

    # @return Data contains all information for this app, including the unmodified one
    attr_accessor :information
    # data = {
    #   'en-US' => {
    #     title: {
    #       value: "Something",
    #       modified: false
    #     },
    #     version_whats_new: {
    #       value: "Some text",
    #       modified: true
    #     }
    #     screenshots: {
    #       '45' => [
    #         Screenshot1
    #       ]
    #     }
    #   }
    # }

    private_constant :METADATA_FILE_NAME, :MAXIMUM_NUMBER_OF_SCREENSHOTS

    INVALID_LANGUAGE_ERROR = "The specified language could not be found. Make sure it is available in FastlaneCore::Languages::ALL_LANGUAGES"

    # You don't have to manually create an AppMetadata object. It will
    # be created when you access the app's metadata ({Deliver::App#metadata})
    # @param app [Deliver::App] The app this metadata is from/for
    # @param dir [String] The app this metadata is from/for
    # @param redownload_package [bool] When true
    #  the current package will be downloaded from iTC before you can
    #  modify any values. This should only be false for unit tests
    # @raise (AppMetadataParameterError) Is thrown when don't pass a correct app object
    def initialize(app, dir, redownload_package = true)
      raise AppMetadataParameterError.new("No valid Deliver::App given") unless app.kind_of?Deliver::App

      @metadata_dir = dir
      @app = app

      if self.class == AppMetadata
        if redownload_package
          # Delete the one that may exists already
          unless Helper.is_test?
            `rm -rf #{dir}/*.itmsp`
          end

          # we want to update the metadata, so first we have to download the existing one
          transporter.download(app, dir)

          # Parse the downloaded package
          parse_package(dir)
        else
          # use_data contains the data to be used. This is the case for unit tests
          parse_package(dir)
        end
      end
    end

    def information
      @information ||= {}
    end

    # Verifies the if the version of iTunesConnect matches the one you pass as parameter
    def verify_version(version_number)
      xml_version = self.fetch_value("//x:version").first['string']
      raise "Version mismatch: on iTunesConnect the latest version is '#{xml_version}', you specified '#{version_number}'" if xml_version != version_number
      true
    end

    # Adds a new locale (language) to the given app
    # @param language (FastlaneCore::Languages::ALL_LANGUAGES) the language you want to add
    # @raise (AppMetadataParameterError) Is thrown when don't pass a correct hash with correct language codes.
    # @return (Bool) Is true, if the language was created. False, when the language alreade existed
    def add_new_locale(language)
      unless FastlaneCore::Languages::ALL_LANGUAGES.include?language
        raise "Language '#{language}' is invalid. It must be in #{FastlaneCore::Languages::ALL_LANGUAGES}."
      end

      if information[language] != nil
        Helper.log.info("Locale '#{language}' already exists. Can not create it again.")
        return false
      end


      locales = fetch_value("//x:locales").first

      new_locale = @data.create_element('locale')
      new_locale['name'] = language
      locales << new_locale

      # Title is the only thing which is required by iTC
      default_title = information.values.first[:title][:value]

      title = @data.create_element('title')
      title.content = default_title
      new_locale << title

      Helper.log.info("Successfully created the new locale '#{language}'. The default title '#{default_title}' was set.")
      Helper.log.info("You can update the title using 'app.metadata.update_title'")

      information[language] ||= {}
      information[language][:title] = { value: default_title, modified: true}

      true
    end


    #####################################################
    # @!group Updating metadata information
    #####################################################

    # Updates the app title
    # @param (Hash) hash The hash should contain the correct language codes ({FastlaneCore::Languages})
    #  as keys.
    # @raise (AppMetadataParameterError) Is thrown when don't pass a correct hash with correct language codes.
    def update_title(hash)
      update_metadata_key(:title, hash)
    end

    # Updates the app description which is shown in the AppStore
    # @param (Hash) hash The hash should contain the correct language codes ({FastlaneCore::Languages})
    #  as keys.
    # @raise (AppMetadataParameterError) Is thrown when don't pass a correct hash with correct language codes.
    def update_description(hash)
      update_metadata_key(:description, hash)
    end

    # Updates the app changelog of the latest version
    # @param (Hash) hash The hash should contain the correct language codes ({FastlaneCore::Languages})
    #  as keys.
    # @raise (AppMetadataParameterError) Is thrown when don't pass a correct hash with correct language codes.
    def update_changelog(hash)
      update_metadata_key(:version_whats_new, hash)

      
      # The code below doesn't work when the app
      # is not in the US App Store
      # https://github.com/KrauseFx/deliver/issues/236#issuecomment-111016436
      # check if we're allowed to do that
      # if FastlaneCore::ItunesSearchApi.fetch(@app.apple_id)
      #   # App is already in the store
      #   update_metadata_key(:version_whats_new, hash)
      # else
      #   # App is not in the store, skipping changelog for now
      #   Helper.log.info "It seems like this it the initial release of your app, which can't contain a changelog. Skipping the changelog for now.".yellow
      # end
    end

    # Updates the Marketing URL
    # @param (Hash) hash The hash should contain the correct language codes ({FastlaneCore::Languages})
    #  as keys.
    # @raise (AppMetadataParameterError) Is thrown when don't pass a correct hash with correct language codes.
    def update_marketing_url(hash)
      update_metadata_key(:software_url, hash)
    end

    # Updates the Support URL
    # @param (Hash) hash The hash should contain the correct language codes ({FastlaneCore::Languages})
    #  as keys.
    # @raise (AppMetadataParameterError) Is thrown when don't pass a correct hash with correct language codes.
    def update_support_url(hash)
      update_metadata_key(:support_url, hash)
    end

    # Updates the Privacy URL
    # @param (Hash) hash The hash should contain the correct language codes ({FastlaneCore::Languages})
    #  as keys.
    # @raise (AppMetadataParameterError) Is thrown when don't pass a correct hash with correct language codes.
    def update_privacy_url(hash)
      update_metadata_key(:privacy_url, hash)
    end

    # Updates the app keywords
    # @param (Hash) hash The hash should contain the correct language codes ({FastlaneCore::Languages})
    #  as keys. The value should be an array of keywords (each keyword is a string)
    # @raise (AppMetadataParameterError) Is thrown when don't pass a correct hash with correct language codes.
    def update_keywords(hash)
      update_localized_value('keywords', hash) do |field, keywords, language|
        raise AppMetadataParameterError.new("Parameter needs to be a hash (each language) with an array of keywords in it (given: #{hash})") unless keywords.kind_of?Array

        if not information[language][:keywords] or keywords.sort != information[language][:keywords][:value].sort
          field.children.remove # remove old keywords

          node_set = Nokogiri::XML::NodeSet.new(@data)
          keywords.each do |word|
            keyword = Nokogiri::XML::Node.new('keyword', @data)
            keyword.content = word
            node_set << keyword
          end

          field.children = node_set

          information[language][:keywords] = { value: keywords, modified: true }
        end
      end
    end

    # Updates the price tier of the given app
    # @param (Integer) tier The tier that should be used from now on
    def update_price_tier(tier)
      raise "Price Tier '#{tier}' must be of type integer".red unless tier.kind_of?Integer
      raise "Invalid price tier '#{tier}' given, must be 0 to 94".red unless (tier.to_i >= 0 and tier.to_i <= 87)

      price = fetch_value("//x:wholesale_price_tier").last
      unless price
        Helper.log.info "No initial pricing found, setting the first one."

        formatted_date = "2015-01-01"
        pricing = Nokogiri.XML("
          <products>
              <product>
                  <territory>WW</territory>
                  <cleared_for_sale>true</cleared_for_sale>
                  <sales_start_date>#{formatted_date}</sales_start_date>
                  <intervals>
                      <interval>
                          <start_date>#{formatted_date}</start_date>
                          <wholesale_price_tier>0</wholesale_price_tier>
                      </interval>
                  </intervals>
                  <allow_volume_discount>true</allow_volume_discount>
              </product>
          </products>")
        software_metadata = fetch_value("//x:software_metadata").last
        software_metadata << pricing.root

        # We're done here, now fetch the element again and set the real price tier
        price = fetch_value("//x:wholesale_price_tier").last
        raise "Something went wrong creating the new price tier" unless price
      end

      price.content = tier
    end

    #####################################################
    # @!group Manually fetching elements from the metadata.xml
    #####################################################

    # Directly fetch XML nodes from the metadata.xml.
    # @example Fetch all keywords
    #  fetch_value("//x:keyword")
    # @example Fetch a specific locale
    #  fetch_value("//x:locale[@name='de-DE']")
    # @example Fetch the node that contains all screenshots for a specific language
    #  fetch_value("//x:locale[@name='de-DE']/x:software_screenshots")
    # @return the requests XML nodes or node set
    def fetch_value(xpath)
      @data.xpath(xpath, "x" => ITUNES_NAMESPACE)
    end


    #####################################################
    # @!group Uploading the updated metadata
    #####################################################

    # Actually uploads the updated metadata to Apple.
    # This method might take a while.
    # @raise (TransporterTransferError) When something goes wrong when uploading
    #  the metadata/app
    def upload!
      unless Helper.is_test?
        # First: Write the current XML state to disk
        File.write("#{@package_path}/#{METADATA_FILE_NAME}", @data.to_xml)
      end

      transporter.upload(@app, @metadata_dir)
    end

    private
      def update_metadata_key(key, hash)
        update_localized_value(key, hash) do |field, new_val, language|
          raise AppMetadataParameterError.new("Parameter needs to be an hash, containg strings.") unless new_val.kind_of?String
          if field.content != new_val
            field.content = new_val
            information[language][key] = { value: new_val, modified: true }
          end
        end
      end

      # @return (Deliver::ItunesTransporter) The iTunesTransporter which is
      #  used to upload/download the app metadata.
      def transporter
        @transporter ||= ItunesTransporter.new
      end

      def update_localized_value(xpath_name, new_value)
        raise AppMetadataParameterError.new("Please pass a hash of languages to this method") unless new_value.kind_of?Hash
        raise AppMetadataParameterError.new("Please pass a block, which updates the resulting node") unless block_given?

        xpath_name = xpath_name.to_s

        # Run through all the locales given by the 'user'
        new_value.each do |language, value|
          create_locale_if_not_exists(language)

          locale = fetch_value("//x:locale[@name='#{language}']").first

          raise AppMetadataParameterError.new("#{INVALID_LANGUAGE_ERROR} (#{language})") unless FastlaneCore::Languages::ALL_LANGUAGES.include?language


          field = locale.search(xpath_name).first

          if not field
            # This entry does not exist yet, so we have to create it
            field = Nokogiri::XML::Node.new(xpath_name, @data)
            locale << field
          end

          yield(field, value, language)
          Helper.log.info "Updated #{xpath_name} for locale #{language}"
        end
      end

      def create_locale_if_not_exists(locale)
        add_new_locale(locale) unless information[locale]
      end

      # Parses the metadata using nokogiri
      def parse_package(path)
        unless path.include?".itmsp"
          path += "/#{@app.apple_id}.itmsp/"
        end
        @package_path = path

        @data ||= Nokogiri::XML(File.read("#{path}/#{METADATA_FILE_NAME}"))
        verify_package
        clean_package
        fill_in_data
      end

      # Checks if there is a non live version available
      # (a new version, or a new app)
      def verify_package
        raise AppMetadataError.new("metadata_token is missing. This package seems to be broken") if fetch_value("//x:metadata_token").count != 1
      end

      # Cleans up the package of stuff we do not want to modify/upload
      def clean_package

        # Remove the live version (if it exists)
        versions = fetch_value("//x:version")
        while versions.count > 1
          versions.last.remove
          versions = fetch_value("//x:version")
        end
        Helper.log.info "Modifying version '#{versions.first['string']}' of app #{@app.app_identifier}"

        # Remove all GameCenter related code
        fetch_value("//x:game_center").remove

        # Remove all InApp purchases
        fetch_value("//x:in_app_purchases").remove

        fetch_value("//x:software_screenshots").remove
      end

      # This will fill in all information we got (from the downloaded metadata.xml file) into self.information
      def fill_in_data
        locales = fetch_value("//x:locale")
        locales.each do |locale|
          language = locale['name']
          information[language] ||= {}

          all_keys = [:title, :description, :version_whats_new, :software_url, :support_url, :privacy_url]

          all_keys.each do |key|
            information[language][key] = {
              value: (locale.search(key.to_s).first.content rescue ''),
              modified: false
            }
          end

          information[language][:keywords] = { value: [], modified: false}
          locale.search('keyword').each do |current|
            information[language][:keywords][:value] << current.content
          end

          information[language][:screenshots] = []
        end
      end
  end
end
