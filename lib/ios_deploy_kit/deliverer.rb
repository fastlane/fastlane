module IosDeployKit
  # This class takes care of handling the whole deployment process
  # This includes:
  # 
  # -) Parsing the Deliverfile
  # -) Storing all the information got from the file
  # -) Triggering the upload process itself
  class Deliverer
    
    # General
    attr_accessor :app
    attr_accessor :deliver_file

    # All the updated/new information we got from the Deliverfile
    attr_accessor :deploy_information

    module ValKey
      APP_IDENTIFIER = :app_identifier
      APP_VERSION = :version
      IPA = :ipa
      DESCRIPTION = :description
      TITLE = :title
      CHANGELOG = :changelog
      SUPPORT_URL = :support_url
      PRIVACY_URL = :privacy_url
      MARKETING_URL = :marketing_url
      KEYWORDS = :keywords
      SCREENSHOTS_PATH = :screenshots_path
    end

    
    
    def initialize(path = nil)
      @deploy_information = {}

      @deliver_file = IosDeployKit::Deliverfile::Deliverfile.new(self, path)
      # Do not put code here...

      # TODO: Also allow passing a hash
      # Make sure to use set_new_value to validate the inputs
    end

    def set_new_value(key, value)
      # TODO: Unit test for that
      
      unless self.class.all_available_keys_to_set.include?key
        raise "Invalid key '#{key}', must be contained in Deliverer::ValKey."
      end

      if @deploy_information[key]      
        Helper.log.warn("You already set a value for key '#{key}'. Overwriting value '#{value}' with new value.")
      end

      @deploy_information[key] = value
    end

    def self.all_available_keys_to_set
      Deliverer::ValKey.constants.collect { |a| Deliverer::ValKey.const_get(a) }
    end


    # This method will take care of the actual deployment process, after we 
    # received all information from the Deliverfile
    def finished_executing_deliver_file
      app_version = @deploy_information[ValKey::APP_VERSION]
      app_identifier = @deploy_information[ValKey::APP_IDENTIFIER]

      errors = IosDeployKit::Deliverfile::Deliverfile

      if @deploy_information[ValKey::IPA]

        @ipa = IosDeployKit::IpaUploader.new(IosDeployKit::App.new(nil, nil), '/tmp/', @deploy_information[ValKey::IPA])

        # We are able to fetch some metadata directly from the ipa file
        # If they were also given in the Deliverfile, we will compare the values

        if app_identifier
          if app_identifier != @ipa.fetch_app_identifier
            raise errors::DeliverfileDSLError.new("App Identifier of IPA does not mtach with the given one")
          end
        else
          app_identifier = @ipa.fetch_app_identifier
        end

        if app_version
          if app_version != @ipa.fetch_app_version
            raise errors::DeliverfileDSLError.new("App Version of IPA does not mtach with the given one")
          end
        else
          app_version = @ipa.fetch_app_version
        end        
      end

      
      raise errors::DeliverfileDSLError.new(errors::MISSING_APP_IDENTIFIER_MESSAGE) unless app_identifier
      raise errors::DeliverfileDSLError.new(errors::MISSING_VERSION_NUMBER_MESSAGE) unless app_version

      Helper.log.debug("Got all information needed to deploy a the update '#{app_version}' for app '#{app_identifier}'")

      @app = IosDeployKit::App.new(nil, app_identifier)

      # Now: set all the updated metadata. We can only do that
      # once the whole file is finished

      # Most important
      @app.metadata.update_title(@deploy_information[ValKey::TITLE]) if @deploy_information[ValKey::TITLE]
      @app.metadata.update_description(@deploy_information[ValKey::DESCRIPTION]) if @deploy_information[ValKey::DESCRIPTION]

      # URLs
      @app.metadata.update_support_url(@deploy_information[ValKey::SUPPORT_URL]) if @deploy_information[ValKey::SUPPORT_URL]
      @app.metadata.update_changelog(@deploy_information[ValKey::CHANGELOG]) if @deploy_information[ValKey::CHANGELOG]
      @app.metadata.update_marketing_url(@deploy_information[ValKey::MARKETING_URL]) if @deploy_information[ValKey::MARKETING_URL]

      # App Keywords
      @app.metadata.update_keywords(@deploy_information[ValKey::KEYWORDS]) if @deploy_information[ValKey::KEYWORDS]

      # Screenshots

      @app.metadata.set_screenshots_from_path(@deploy_information[ValKey::SCREENSHOTS_PATH]) if @deploy_information[ValKey::SCREENSHOTS_PATH]

      # unless Helper.is_test?
        @app.metadata.upload!
      # end


      # IPA File
      # The IPA file has to be handles seperatly
      if @ipa
        
        @ipa.upload!
      end

    end
  end
end