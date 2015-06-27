# Inspired by https://github.com/CocoaPods/Core/blob/master/lib/cocoapods-core/podfile/dsl.rb
require 'credentials_manager/password_manager'

module Deliver
  module Deliverfile
    class Deliverfile
      module DSL
        MISSING_VALUE_ERROR_MESSAGE = "You have to pass either a value or a block to the given method."
        SPECIFY_LANGUAGE_FOR_VALUE = "You have to specify the language of the given value. Either set a default language using 'default_language \"en-US\"' on the top of the file or pass a hash containing the language codes"

        MISSING_APP_IDENTIFIER_MESSAGE = "You have to pass a valid app identifier using the Deliver file. (e.g. 'app_identifier \"net.sunapps.app\"')"
        MISSING_VERSION_NUMBER_MESSAGE = "You have to pass a valid version number using the Deliver file. (e.g. 'version \"1.0\"')"
        INVALID_IPA_FILE_GIVEN = "The given ipa file seems to be wrong. Make sure it's a valid ipa file."

        class DeliverfileDSLError < StandardError
        end

        # Setting all the metadata
        def method_missing(method_sym, *arguments, &block)
          allowed = Deliver::Deliverer.all_available_keys_to_set
          not_translated = [:ipa, :app_identifier, :apple_id, :screenshots_path, :config_json_folder, 
                            :submit_further_information, :copyright, :primary_category, :secondary_category,
                            :primary_subcategories, :secondary_subcategories,
                            :automatic_release, :app_review_information, :ratings_config_path, :price_tier,
                            :app_icon, :apple_watch_app_icon]

          if allowed.include?(method_sym)
            value = arguments.first
            value = block.call if (value == nil and block != nil)

            if value == nil
              Helper.log.error(caller)
              Helper.log.fatal("No value or block passed to method '#{method_sym}'")
              raise DeliverfileDSLError.new(MISSING_VALUE_ERROR_MESSAGE.red)
            end

            if (not value.kind_of?Hash) and (not not_translated.include?method_sym)
              # The user should pass a hash for multi-lang values
              # Maybe he at least set a default language
              if @default_language
                value = { @default_language => value }
              else
                raise DeliverfileDSLError.new(SPECIFY_LANGUAGE_FOR_VALUE.red)
              end
            end

            @deliver_data.set_new_value(method_sym, value)
          else
            # Check if it's a block (e.g. run tests)
            if Deliver::Deliverer.all_available_blocks_to_set.include?method_sym
              if block
                @deliver_data.set_new_block(method_sym, block)
              else
                raise DeliverfileDSLError.new("Value for #{method_sym} must be a Ruby block. Use '#{method_sym}' do ... end.".red)
              end
            else
              # Couldn't find this particular method
              Helper.log.error("Could not find method '#{method_sym}'. Available methods: #{allowed.collect { |a| a.to_s }}")
            end
          end
        end

        # This method can be used to set a default language, which is used
        # when passing a string to metadata changes, instead of a hash
        # containing multiple languages.
        #
        # This is approach only is recommend for deployments where you are only
        # supporting one language.
        #
        # The language itself must be included in {FastlaneCore::Languages::ALL_LANGUAGES}.
        # @example
        #  default_language 'en-US'
        # @example
        #  default_language 'de-DE'
        def default_language(value = nil)
          # Verify, default_language is on the top of the file
          already_set = @deliver_data.deliver_process.deploy_information
          minimum = (already_set[:skip_pdf] ? 4 : 3) # skip_pdf + blocks
          if already_set.count > minimum
            raise "'default_language' must be on the top of the Deliverfile.".red
          end


          @default_language = value
          @default_language ||= yield if block_given?
          Helper.log.debug("Set default language to #{@default_language}")
          @deliver_data.set_new_value(:default_language, @default_language)
        end

        # Pass the path to the ipa file which should be uploaded
        # @raise (DeliverfileDSLError) occurs when you pass an invalid path to the
        #  IPA file.
        def ipa(value = nil, &block)
          DSL.validate_ipa!(value) if value # to catch errors early

          @deliver_data.set_new_value(Deliverer::ValKey::IPA, (value || block))
        end

        # Pass the path to the ipa file (beta version) which should be uploaded
        # @raise (DeliverfileDSLError) occurs when you pass an invalid path to the
        #  IPA file.
        def beta_ipa(value = nil, &block)
          DSL.validate_ipa!(value) if value # to catch errors early

          @deliver_data.set_new_value(Deliverer::ValKey::BETA_IPA, (value || block))
        end

        # This will set the email address of the Apple ID to be used
        def email(value)
          value ||= yield if block_given?
          CredentialsManager::PasswordManager.logout # if it was logged in already (with fastlane)
          CredentialsManager::PasswordManager.shared_manager(value)
        end

        # This will hide the output of the iTunes Connect transporter while uploading/downloading
        def hide_transporter_output
          ItunesTransporter.hide_transporter_output
        end

        # Set the apps new version number.
        #
        # If you do not set this, it will automatically being fetched from the
        # IPA file.
        def version(value = nil)
          value ||= yield if block_given?
          raise DeliverfileDSLError.new(MISSING_VALUE_ERROR_MESSAGE.red) unless value
          raise DeliverfileDSLError.new("The app version should be a string".red) unless value.kind_of?(String)

          @deliver_data.set_new_value(Deliverer::ValKey::APP_VERSION, value)
        end

        # Only verifies the file type of the ipa path and if the file can be found. Is also called from deliver_process
        # This will raise a DeliverfileDSLError if something goes wrong
        def self.validate_ipa!(value)
          raise DeliverfileDSLError.new(INVALID_IPA_FILE_GIVEN.red) unless value
          raise DeliverfileDSLError.new(INVALID_IPA_FILE_GIVEN.red) unless value.kind_of?String
          raise DeliverfileDSLError.new(INVALID_IPA_FILE_GIVEN.red) unless value.include?".ipa"
        end
      end
    end
  end
end
