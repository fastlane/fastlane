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

    def set_app_identifier(str)
      # That's what we've been waiting for.
      # We need the app identifier to fetch the Apple ID to actually do something
      @app = IosDeployKit::App.new(nil, str)
    end


    # This method will take care of the actual deployment process, after we 
    # received all information from the Deliverfile
    def finished_executing_deliver_file
      app_version = @deploy_information[ValKey::APP_VERSION]
      errors = IosDeployKit::Deliverfile::Deliverfile
      raise errors::DeliverfileDSLError.new(errors::MISSING_APP_IDENTIFIER_MESSAGE) unless @app
      raise errors::DeliverfileDSLError.new(errors::MISSING_VERSION_NUMBER_MESSAGE) unless app_version

      Helper.log.debug("Got all information needed to deploy a the update '#{app_version}' for app '#{@app.apple_id}'")

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

      # IPA File
      # @app.metadata.update_keywords(@deploy_information[ValKey::KEYWORDS]) if @deploy_information[ValKey::KEYWORDS] # TODO

      unless Helper.is_test?
        @app.metadata.upload!
      end

    end
  end
end