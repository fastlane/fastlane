module Deliver
  # This class will collect the deploy data from different places
  # This will trigger:
  #
  # - Parsing the Deliverfile
  # - Temporary storing all the information got from the file, until the file finished executing
  # - Triggering the upload process itself using the DeliverProcess class
  class Deliverer
    # @return (Deliver::Deliverfile::Deliverfile) A reference
    #  to the Deliverfile which is currently being used.
    attr_accessor :deliver_file

    # @return (Deliver::DeliverProcess) The class which handels the deployment process itself
    attr_accessor :deliver_process

    module ValKey
      APP_IDENTIFIER = :app_identifier
      APPLE_ID = :apple_id
      APP_VERSION = :version
      IPA = :ipa
      DESCRIPTION = :description
      TITLE = :title
      BETA_IPA = :beta_ipa
      IS_BETA_IPA = :is_beta_ipa
      SKIP_DEPLOY = :skip_deploy
      CHANGELOG = :changelog
      SUPPORT_URL = :support_url
      PRIVACY_URL = :privacy_url
      MARKETING_URL = :marketing_url
      KEYWORDS = :keywords
      SCREENSHOTS_PATH = :screenshots_path
      DEFAULT_LANGUAGE = :default_language
      CONFIG_JSON_FOLDER = :config_json_folder # Path to a folder containing a configuration file and including screenshots
      SKIP_PDF = :skip_pdf
      SUBMIT_FURTHER_INFORMATION = :submit_further_information # export compliance, content rights and advertising identifier
      PRICE_TIER = :price_tier
      APP_ICON = :app_icon
      APPLE_WATCH_APP_ICON = :apple_watch_app_icon

      COPYRIGHT = :copyright
      PRIMARY_CATEGORY = :primary_category
      SECONDARY_CATEGORY = :secondary_category
      PRIMARY_SUBCATEGORIES = :primary_subcategories
      SECONDARY_SUBCATEGORIES = :secondary_subcategories
      
      AUTOMATIC_RELEASE = :automatic_release # should the update go live after approval
      RATINGS_CONFIG_PATH = :ratings_config_path # a path to the configuration for the app's ratings

      APP_REVIEW_INFORMATION = :app_review_information
      # Supported
        # first_name
        # last_name
        # phone_number
        # email_address
        # demo_user
        # demo_password
        # notes
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
    # @param (Bool) force Runs a deployment without verifying any information. This can be
    # used for build servers. If this is set to false a PDF summary will be generated and opened
    def initialize(path = nil, hash: nil, force: false, is_beta_ipa: false, skip_deploy: false)
      @deliver_process = DeliverProcess.new
      @deliver_process.deploy_information[ValKey::SKIP_PDF] = true if force
      @deliver_process.deploy_information[ValKey::IS_BETA_IPA] = is_beta_ipa
      @deliver_process.deploy_information[ValKey::SKIP_DEPLOY] = skip_deploy

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
        raise "Invalid key '#{key}', must be contained in Deliverer::ValKey.".red
      end

      if @deliver_process.deploy_information[key]
        Helper.log.warn("You already set a value for key '#{key}'. Overwriting with new value '#{value}'.")
      end

      @deliver_process.deploy_information[key] = value
    end

    # Sets a new block for a specific key
    def set_new_block(key, block)
      @deliver_process.deploy_information[:blocks][key] = block
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

    # This method will take care of the actual deployment process, after we
    # received all information from the Deliverfile.
    #
    # This method will be called from the {Deliver::Deliverfile} after
    # it is finished executing the Ruby script.
    def finished_executing_deliver_file
      deliver_process.run
    end
  end
end
