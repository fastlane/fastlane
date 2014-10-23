module Deliver
  # This class takes care of handling the whole deployment process
  # This includes:
  # 
  # - Parsing the Deliverfile
  # - Temporary storing all the information got from the file, until the file finished executing
  # - Triggering the upload process itself
  class Deliverer
    # DeliverUnitTestsError is triggered, when the unit tests of the given block failed.
    class DeliverUnitTestsError < StandardError
    end
    
    # General

    # @return (Deliver::App) The App that is currently being edited.
    attr_accessor :app
    # @return (Deliver::Deliverfile::Deliverfile) A reference
    #  to the Deliverfile which is currently being used.
    attr_accessor :deliver_file

    # @return (Hash) All the updated/new information we got from the Deliverfile. 
    #  is used to store the deploy information until the Deliverfile finished running.
    attr_accessor :deploy_information

    module ValKey
      APP_IDENTIFIER = :app_identifier
      APPLE_ID = :apple_id
      APP_VERSION = :version
      IPA = :ipa
      BETA_IPA = :beta_ipa
      DESCRIPTION = :description
      TITLE = :title
      CHANGELOG = :changelog
      SUPPORT_URL = :support_url
      PRIVACY_URL = :privacy_url
      MARKETING_URL = :marketing_url
      KEYWORDS = :keywords
      SCREENSHOTS_PATH = :screenshots_path
      DEFAULT_LANGUAGE = :default_language
      SUPPORTED_LANGUAGES = :supported_languages
      CONFIG_JSON_FOLDER = :config_json_folder # path to a folder containing json files for all supported languages, including screenshots
      SKIP_PDF = :skip_pdf
    end

    module AllBlocks
      UNIT_TESTS = :unit_tests
      SUCCESS = :success
      ERROR = :error
    end

    
    # Start a new deployment process based on the given Deliverfile
    # @param (String) path The path to the Deliverfile.
    # @param (Hash) hash You can pass a hash instead of a path to basically
    #  give all the information required (see {Deliverer::ValKey} for available options)
    def initialize(path = nil, hash = nil)
      @deploy_information = {}

      if hash
        hash.each do |key, value|
          # we still call this interface to verify the inputs correctly
          set_new_value(key, value)
        end

        finished_executing_deliver_file
      else
        @deliver_file = Deliver::Deliverfile::Deliverfile.new(self, path)
      end

      # Do not put code here...
    end

    # This method is internally called from the Deliverfile DSL
    # to set a value for a given key. This method will also verify if 
    # the key is valid.
    def set_new_value(key, value)
      unless self.class.all_available_keys_to_set.include?key
        raise "Invalid key '#{key}', must be contained in Deliverer::ValKey."
      end

      if @deploy_information[key]      
        Helper.log.warn("You already set a value for key '#{key}'. Overwriting value '#{value}' with new value.")
      end

      @deploy_information[key] = value
    end

    # Sets a new block for a specific key
    def set_new_block(key, block)
      @active_blocks ||= {}
      @active_blocks[key] = block
    end

    # An array of all available options to be set a deployment_information.
    # 
    # Is used to verify user inputs
    # @return (Hash) The array of symbols
    def self.all_available_keys_to_set
      Deliverer::ValKey.constants.collect { |a| Deliverer::ValKey.const_get(a) }
    end

    # An array of all available blocks to be set for a deployment
    # 
    # Is used to verify user inputs
    # @return (Hash) The array of symbols
    def self.all_available_blocks_to_set
      Deliverer::AllBlocks.constants.collect { |a| Deliverer::AllBlocks.const_get(a) }
    end

    # This will check which file exist in this folder and load their content
    def load_config_json_folder
      matching = {
        'title' => ValKey::TITLE,
        'description' => ValKey::DESCRIPTION,
        'version_whats_new' => ValKey::CHANGELOG,
        'keywords' => ValKey::KEYWORDS,
        'privacy_url' => ValKey::PRIVACY_URL,
        'software_url' => ValKey::MARKETING_URL,
        'support_url' => ValKey::SUPPORT_URL
      }

      Dir.glob("#{@deploy_information[:config_json_folder]}/*").each do |path|
        if File.exists?(path) and not File.directory?(path)
          language = path.split("/").last.split(".").first # TODO: this should be improved
          data = JSON.parse(File.read(path))

          matching.each do |key, value|

            if data[key]
              @deploy_information[value] ||= {}
              @deploy_information[value][language] = data[key]
            end

          end
        end
      end
    end

    # This method will take care of the actual deployment process, after we 
    # received all information from the Deliverfile. 
    # 
    # This method will be called from the {Deliver::Deliverfile} after
    # it is finished executing the Ruby script.
    def finished_executing_deliver_file
      begin
        @active_blocks ||= {}

        app_version = @deploy_information[ValKey::APP_VERSION]
        app_identifier = @deploy_information[ValKey::APP_IDENTIFIER]
        apple_id = @deploy_information[ValKey::APPLE_ID]

        errors = Deliver::Deliverfile::Deliverfile

        used_ipa_file = @deploy_information[ValKey::IPA] || @deploy_information[ValKey::BETA_IPA]
        is_beta_build = @deploy_information[ValKey::BETA_IPA] != nil

        # Verify or complete the IPA information (app identifier and app version)
        if used_ipa_file

          @ipa = Deliver::IpaUploader.new(Deliver::App.new, '/tmp/', used_ipa_file, is_beta_build)

          # We are able to fetch some metadata directly from the ipa file
          # If they were also given in the Deliverfile, we will compare the values

          if app_identifier
            if app_identifier != @ipa.fetch_app_identifier
              raise errors::DeliverfileDSLError.new("App Identifier of IPA does not match with the given one (#{app_identifier} != #{@ipa.fetch_app_identifier})")
            end
          else
            app_identifier = @ipa.fetch_app_identifier
          end

          if app_version
            if app_version != @ipa.fetch_app_version
              raise errors::DeliverfileDSLError.new("App Version of IPA does not match with the given one (#{app_version} != #{@ipa.fetch_app_version})")
            end
          else
            app_version = @ipa.fetch_app_version
          end        
        end

        
        raise errors::DeliverfileDSLError.new(errors::MISSING_APP_IDENTIFIER_MESSAGE) unless app_identifier
        raise errors::DeliverfileDSLError.new(errors::MISSING_VERSION_NUMBER_MESSAGE) unless app_version

        Helper.log.info("Got all information needed to deploy a the update '#{app_version}' for app '#{app_identifier}'")

        @app = Deliver::App.new(app_identifier: app_identifier,
                                           apple_id: apple_id)

        if @ipa and not is_beta_build
          # This is a real release, which should also upload the ipa file onto production
          @app.create_new_version!(app_version) unless Helper.is_test?
          @app.metadata.verify_version(app_version)
        end

        if @active_blocks[:unit_tests]
          result = @active_blocks[:unit_tests].call
          if result != true and (result || 0).to_i != 1
            raise DeliverUnitTestsError.new("Unit tests failed. Got result: '#{result}'. Need 'true' or 1 to succeed.")
          end
        end

        ##########################################
        # Everything is ready for deployment
        ##########################################

        if @deploy_information[ValKey::SUPPORTED_LANGUAGES]
          @deploy_information[ValKey::SUPPORTED_LANGUAGES].each do |language|
            @app.metadata.add_new_locale(language)
          end
        end

        # Config JS Folder, which is used when starting with the Quick Start
        # This has to be before the other things
        if @deploy_information[:config_json_folder]
          load_config_json_folder
        end


        # Now: set all the updated metadata. We can only do that
        # once the whole file is finished

        # Most important
        @app.metadata.update_title(@deploy_information[ValKey::TITLE]) if @deploy_information[ValKey::TITLE]
        @app.metadata.update_description(@deploy_information[ValKey::DESCRIPTION]) if @deploy_information[ValKey::DESCRIPTION]

        # URLs
        @app.metadata.update_support_url(@deploy_information[ValKey::SUPPORT_URL]) if @deploy_information[ValKey::SUPPORT_URL]
        @app.metadata.update_changelog(@deploy_information[ValKey::CHANGELOG]) if @deploy_information[ValKey::CHANGELOG]
        @app.metadata.update_marketing_url(@deploy_information[ValKey::MARKETING_URL]) if @deploy_information[ValKey::MARKETING_URL]
        @app.metadata.update_privacy_url(@deploy_information[ValKey::PRIVACY_URL]) if @deploy_information[ValKey::PRIVACY_URL]

        # App Keywords
        @app.metadata.update_keywords(@deploy_information[ValKey::KEYWORDS]) if @deploy_information[ValKey::KEYWORDS]

        # Screenshots
        screens_path = @deploy_information[ValKey::SCREENSHOTS_PATH]
        if screens_path
          if not @app.metadata.set_all_screenshots_from_path(screens_path)
            # This path does not contain folders for each language
            if screens_path.kind_of?String
              if @deploy_information[ValKey::DEFAULT_LANGUAGE]
                screens_path = { @deploy_information[ValKey::DEFAULT_LANGUAGE] => screens_path }
              else
                Helper.log.error"You have to have folders for the screenshots (#{screens_path}) for each language (e.g. en-US, de-DE) or provide a default language or provide a hash with one path for each language"
              end
            end
            @app.metadata.set_screenshots_for_each_language(screens_path)
          end
        end
        
        if @deploy_information[ValKey::SKIP_PDF] or is_beta_build
          Helper.log.debug "PDF verify was skipped"
        else
          # Everything is prepared for the upload
          # We may have to ask the user if that's okay
          pdf_path = PdfGenerator.new.render(self)
          unless Helper.is_test?
            puts "----------------------------------------------------------------------------"
            puts "Verifying the upload via the PDF file can be disabled by either adding"
            puts "'skip_pdf true' to your Deliverfile or using the flag -f when using the CLI."
            puts "----------------------------------------------------------------------------"

            system("open '#{pdf_path}'")
            okay = agree("Does the PDF on path '#{pdf_path}' look okay for you? (blue = updated) (y/n)", true)
            raise "Did not upload the metadata, because the PDF file was rejected by the user" unless okay
          end
        end


        result = @app.metadata.upload!
        raise "Error uploading app metadata" unless result == true

        # IPA File
        # The IPA file has to be handles seperatly
        if @ipa
          @ipa.app = @app # we now have the resulting app
          result = @ipa.upload! # Important: this will also actually deploy the app on iTunesConnect
        else
          Helper.log.warn "No IPA file given. Only the metadata were uploaded. If you want to deploy a full update, provide an ipa file."
        end

        if result == true
          @active_blocks[:success].call if @active_blocks[:success]
        else
          raise "Error uploading the ipa file"
        end

      rescue Exception => ex
        if @active_blocks[:error]
          # Custom error handling, we just call this one
          @active_blocks[:error].call(ex)
        else
          # Re-Raise the exception
          raise ex
        end
      end
    end
  end
end