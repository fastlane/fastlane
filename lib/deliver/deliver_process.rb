module Deliver
  # This class takes care of verifying all inputs and triggering the upload process
  class DeliverProcess

    # DeliverUnitTestsError is triggered, when the unit tests of the given block failed.
    class DeliverUnitTestsError < StandardError
    end

    # @return (Deliver::App) The App that is currently being edited.
    attr_accessor :app

    # @return (Deliver::IpaUploader) The IPA uploader that is currently being used.
    attr_accessor :ipa

    # @return (Hash) All the updated/new information we got from the Deliverfile.
    #  is used to store the deploy information until the Deliverfile finished running.
    attr_accessor :deploy_information

    # @return (String): The app identifier of the currently used app (e.g. com.krausefx.app)
    attr_accessor :app_identifier

    def initialize(deploy_information = nil)
      @deploy_information = deploy_information || {}
      @deploy_information[:blocks] ||= {}
    end

    def run
      begin
        run_unit_tests
        fetch_information_from_ipa_file

        verify_ipa_file

        Helper.log.info("Got all information needed to deploy a new update ('#{@app_version}') for app '#{@app_identifier}'")

        create_app
        verify_app_on_itunesconnect

        unless is_beta_build?
          # App Metdata will not be updated for beta builds

          load_metadata_from_config_json_folder # the json file generated from the quick start # deprecated
          load_metadata_folder # this is the new way of defining app metadata
          set_app_metadata
          set_screenshots

          verify_pdf_file

          additional_itc_information # e.g. copyright, age rating

          trigger_metadata_upload
        end

        # Always upload a new ipa (except if none was given)
        trigger_ipa_upload

        call_success_block
      rescue => ex
        call_error_block(ex)
      end
    end

    #####################################################
    # @!group All the methods
    #####################################################

    def run_unit_tests
      if @deploy_information[:blocks][:unit_tests]
        result = @deploy_information[:blocks][:unit_tests].call
        if result
          Helper.log.debug("Unit tests successful".green)
        else
          raise DeliverUnitTestsError.new("Unit tests failed. Got result: '#{result}'. Need 'true' or 1 to succeed.".red)
        end
      end
    end

    def fetch_information_from_ipa_file
      @app_version = @deploy_information[Deliverer::ValKey::APP_VERSION]
      @app_identifier = @deploy_information[Deliverer::ValKey::APP_IDENTIFIER]

      used_ipa_file = ENV["IPA_OUTPUT_PATH"]# if (ENV["IPA_OUTPUT_PATH"] and File.exists?(ENV["IPA_OUTPUT_PATH"]))

      if is_release_build?
        used_ipa_file = @deploy_information[:ipa] if @deploy_information[:ipa]
      elsif is_beta_build?
        used_ipa_file = @deploy_information[:beta_ipa] if @deploy_information[:beta_ipa]
      end

      if used_ipa_file.kind_of?Proc
        # The user provided a block. We only want to execute the block now, since it might be a long build step
        used_ipa_file = used_ipa_file.call

        Deliverfile::Deliverfile::DSL.validate_ipa!(used_ipa_file)
      end
      
      if (used_ipa_file || '').length == 0 and is_beta_build?
        # Beta Release but no ipa given
        used_ipa_file = Dir["*.ipa"].first
        
        unless used_ipa_file
          raise "Could not find an ipa file for 'beta' mode. Provide one using `beta_ipa do ... end` in your Deliverfile.".red
        end
      end

      ENV["DELIVER_IPA_PATH"] = used_ipa_file

      if used_ipa_file
        upload_strategy = Deliver::IPA_UPLOAD_STRATEGY_APP_STORE
        if is_beta_build?
          upload_strategy = Deliver::IPA_UPLOAD_STRATEGY_BETA_BUILD
        end
        if skip_deployment?
          upload_strategy = Deliver::IPA_UPLOAD_STRATEGY_JUST_UPLOAD
          Helper.log.info "Skipping submission of app update"
        end

        @ipa = Deliver::IpaUploader.new(Deliver::App.new, '/tmp/', used_ipa_file, upload_strategy)

        # We are able to fetch some metadata directly from the ipa file
        # If they were also given in the Deliverfile, we will compare the values
        @app_identifier = verify_app_identifier(@app_identifier)
        @app_version = verify_app_version(@app_version)
      end
    end

    def fetch_app_identifier_from_app_file
      @app_identifier = (CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier) rescue nil)
    end

    def verify_ipa_file
      fetch_app_identifier_from_app_file unless @app_identifier
      raise Deliverfile::Deliverfile::DeliverfileDSLError.new(Deliverfile::Deliverfile::MISSING_APP_IDENTIFIER_MESSAGE.red) unless @app_identifier
      raise Deliverfile::Deliverfile::DeliverfileDSLError.new(Deliverfile::Deliverfile::MISSING_VERSION_NUMBER_MESSAGE.red) unless @app_version
    end

    def create_app
      @app = Deliver::App.new(app_identifier: @app_identifier,
                                    apple_id: @deploy_information[Deliverer::ValKey::APPLE_ID])
    end

    def verify_app_on_itunesconnect
      if (@ipa and is_release_build?) or !@ipa
        # This is a real release, which should also upload the ipa file onto production
        @app.create_new_version!(@app_version) unless Helper.is_test?
        @app.metadata.verify_version(@app_version) if @ipa
      end
    end

    def options_mapping
      {
        'title' => Deliverer::ValKey::TITLE,
        'description' => Deliverer::ValKey::DESCRIPTION,
        'version_whats_new' => Deliverer::ValKey::CHANGELOG,
        'keywords' => Deliverer::ValKey::KEYWORDS,
        'privacy_url' => Deliverer::ValKey::PRIVACY_URL,
        'software_url' => Deliverer::ValKey::MARKETING_URL,
        'support_url' => Deliverer::ValKey::SUPPORT_URL
      }
    end

    def load_metadata_from_config_json_folder
      return unless @deploy_information[Deliverer::ValKey::CONFIG_JSON_FOLDER]

      file_path = @deploy_information[:config_json_folder]
      unless file_path.split("/").last.include?"metadata.json"
        file_path += "/metadata.json"
      end

      raise "Could not find metadatafile at path '#{file_path}'".red unless File.exists?file_path

      content = JSON.parse(File.read(file_path))
      content.each do |language, current|

        options_mapping.each do |key, value|
          if current[key]
            @deploy_information[value] ||= {}
            @deploy_information[value][language] ||= current[key]
          end
        end
      end
    end

    def load_metadata_folder
      # Fetch the information from the ./metadata folder if it exists
      metadata_folder = './metadata'
      return unless File.exists?metadata_folder

      Dir[File.join(metadata_folder, '*')].each do |language_folder|
        language = File.basename(language_folder)

        options_mapping.each do |key, value|
          content = File.read(File.join(language_folder, "#{key}.txt")) rescue nil
          next unless content
          content = content.split("\n") if key == 'keywords'
          @deploy_information[value] ||= {}
          @deploy_information[value][language] ||= content

          Helper.log.info "Successfully loaded content from '#{key}.txt' for language #{language_folder}"
        end
      end
    end

    def set_app_metadata
      @app.metadata.update_title(@deploy_information[Deliverer::ValKey::TITLE]) if @deploy_information[Deliverer::ValKey::TITLE]
      @app.metadata.update_description(@deploy_information[Deliverer::ValKey::DESCRIPTION]) if @deploy_information[Deliverer::ValKey::DESCRIPTION]

      @app.metadata.update_support_url(@deploy_information[Deliverer::ValKey::SUPPORT_URL]) if @deploy_information[Deliverer::ValKey::SUPPORT_URL]
      @app.metadata.update_changelog(@deploy_information[Deliverer::ValKey::CHANGELOG]) if @deploy_information[Deliverer::ValKey::CHANGELOG]
      @app.metadata.update_marketing_url(@deploy_information[Deliverer::ValKey::MARKETING_URL]) if @deploy_information[Deliverer::ValKey::MARKETING_URL]
      @app.metadata.update_privacy_url(@deploy_information[Deliverer::ValKey::PRIVACY_URL]) if @deploy_information[Deliverer::ValKey::PRIVACY_URL]

      @app.metadata.update_keywords(@deploy_information[Deliverer::ValKey::KEYWORDS]) if @deploy_information[Deliverer::ValKey::KEYWORDS]

      @app.metadata.update_price_tier(@deploy_information[Deliverer::ValKey::PRICE_TIER]) if @deploy_information[Deliverer::ValKey::PRICE_TIER]
    end


    def set_screenshots
      screens_path = @deploy_information[Deliverer::ValKey::SCREENSHOTS_PATH]

      if (ENV["DELIVER_SCREENSHOTS_PATH"] || '').length > 0
        Helper.log.warn "Overwriting screenshots path from config (#{screens_path}) with (#{ENV["DELIVER_SCREENSHOTS_PATH"]})".yellow
        screens_path = ENV["DELIVER_SCREENSHOTS_PATH"]
      end

      screens_path ||= "./screenshots/" # default value
      
      if screens_path
        # Not using Snapfile. Not a good user.
        if not @app.metadata.set_all_screenshots_from_path(screens_path)
          # This path does not contain folders for each language
          if screens_path.kind_of?String
            if @deploy_information[Deliverer::ValKey::DEFAULT_LANGUAGE]
              screens_path = { @deploy_information[Deliverer::ValKey::DEFAULT_LANGUAGE] => screens_path } # use the default language
              @deploy_information[Deliverer::ValKey::SCREENSHOTS_PATH] = screens_path
            else
              Helper.log.error "You must have folders for the screenshots (#{screens_path}) for each language (e.g. en-US, de-DE)."
              screens_path = nil
            end
          end
          @app.metadata.set_screenshots_for_each_language(screens_path) if screens_path
        end
      end
    end

    def verify_pdf_file
      if @deploy_information[Deliverer::ValKey::SKIP_PDF]
        Helper.log.debug "PDF verify was skipped"
      else
        # Everything is prepared for the upload
        # We may have to ask the user if that's okay
        pdf_path = PdfGenerator.new.render(self)
        unless Helper.is_test?
          puts "----------------------------------------------------------------------------"
          puts "Verifying the upload via the PDF file can be disabled by either adding"
          puts "'skip_pdf true' to your Deliverfile or using the flag --force."
          puts "----------------------------------------------------------------------------"

          system("open '#{pdf_path}'")
          okay = agree("Does the PDF on path '#{pdf_path}' look okay for you? (blue = updated) (y/n)", true)

          unless okay
            dir ||= app.get_metadata_directory
            dir += "/#{app.apple_id}.itmsp"
            FileUtils.rm_rf(dir) unless Helper.is_test?
            raise "Did not upload the metadata, because the PDF file was rejected by the user".yellow
          end
        end
      end
    end

    def trigger_metadata_upload
      result = @app.metadata.upload!
      raise "Error uploading app metadata".red unless result == true
    end

    def additional_itc_information
      # e.g. rating or copyright
      itc = ItunesConnect.new
      itc.set_copyright!(@app, @deploy_information[Deliverer::ValKey::COPYRIGHT]) if @deploy_information[Deliverer::ValKey::COPYRIGHT]
      itc.set_app_review_information!(@app, @deploy_information[Deliverer::ValKey::APP_REVIEW_INFORMATION]) if @deploy_information[Deliverer::ValKey::APP_REVIEW_INFORMATION]
      itc.set_release_after_approval!(@app, @deploy_information[Deliverer::ValKey::AUTOMATIC_RELEASE]) if @deploy_information[Deliverer::ValKey::AUTOMATIC_RELEASE] != nil

      # Categories
      primary = @deploy_information[Deliverer::ValKey::PRIMARY_CATEGORY]
      secondary = @deploy_information[Deliverer::ValKey::SECONDARY_CATEGORY]
      itc.set_categories!(@app, primary, secondary) if (primary or secondary)

      # App Rating
      itc.set_app_rating!(@app, @deploy_information[Deliverer::ValKey::RATINGS_CONFIG_PATH]) if @deploy_information[Deliverer::ValKey::RATINGS_CONFIG_PATH]

      # App Icon
      itc.upload_app_icon!(@app, @deploy_information[Deliverer::ValKey::APP_ICON]) if @deploy_information[Deliverer::ValKey::APP_ICON]

      # Apple Watch App Icon
      itc.upload_apple_watch_app_icon!(@app, @deploy_information[Deliverer::ValKey::APPLE_WATCH_APP_ICON]) if @deploy_information[Deliverer::ValKey::APPLE_WATCH_APP_ICON]
    end

    def trigger_ipa_upload
      if @ipa
        @ipa.app = @app # we now have the resulting app
        result = @ipa.upload! # Important: this will also actually deploy the app on iTunesConnect
        raise "Error uploading ipa file".red unless result == true
      else
        Helper.log.warn "No IPA file given. Only the metadata was uploaded. If you want to deploy a full update, provide an ipa file."
      end
    end

    def call_success_block
      if @deploy_information[:blocks][:success]
        @deploy_information[:blocks][:success].call(hash_for_callback)
      end
    end

    def call_error_block(ex)
      if @deploy_information[:blocks][:error]
        # Custom error handling, we just call this one
        @deploy_information[:blocks][:error].call(hash_for_callback(ex))
      end
      
      # Re-Raise the exception
      raise ex
    end

    private
      #####################################################
      # @!group All the helper methods
      #####################################################

      def hash_for_callback(error = nil)
        {
          error: error,
          app_version: @app_version,
          app_identifier: @app_identifier,
          skipped_deploy: skip_deployment?,
          is_release_build: is_release_build?,
          is_beta_build: is_beta_build?,
          ipa_path: ENV["DELIVER_IPA_PATH"]
        }
      end

      def verify_app_identifier(app_identifier)
        if app_identifier
          if @ipa.fetch_app_identifier and app_identifier != @ipa.fetch_app_identifier
            raise Deliver::Deliverfile::Deliverfile::DeliverfileDSLError.new("App Identifier of IPA does not match with the given one ('#{app_identifier}' != '#{@ipa.fetch_app_identifier}')".red)
          end
        else
          app_identifier = @ipa.fetch_app_identifier
        end
        return app_identifier
      end

      def verify_app_version(app_version)
        if app_version
          if @ipa.fetch_app_version and app_version != @ipa.fetch_app_version
            raise Deliver::Deliverfile::Deliverfile::DeliverfileDSLError.new("App Version of IPA does not match with the given one (#{app_version} != #{@ipa.fetch_app_version})".red)
          end
        else
          app_version = @ipa.fetch_app_version
        end
        return app_version
      end

      def skip_deployment?
        @deploy_information[Deliverer::ValKey::SKIP_DEPLOY]
      end

      def is_release_build?
        is_beta_build? == false
      end

      def is_beta_build?
        @deploy_information[Deliverer::ValKey::IS_BETA_IPA]
      end
  end
end
