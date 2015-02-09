module Deliver  
  # Everything related to submitting the app
  class ItunesConnect
    
    # This will put the latest uploaded build as a new beta build
    def put_build_into_beta_testing!(app, version_number)
      begin
        verify_app(app)
        open_app_page(app)

        Helper.log.info("Choosing the latest build on iTunesConnect for beta distribution")

        sleep 3
        click_on "Prerelease"
        sleep 3

        wait_for_preprocessing


        # Beta Switches
        if all(".switcher.ng-binding.checked").count == 0
          raise "Looks like Beta Testing is not yet enabled for this app. Open '#{current_url}' and enable TestFlight Beta Testing.".red
        end
        
        if all(".bt-version > a").count == 0
          raise "Couldn't find any builds. Please check the iTunes Conncet page: '#{current_url}'".red
        end

        # We might have to wait until the second part of "Processing" is finished
        while first("tr > td.bt-internal").text == "Processing"
          Helper.log.debug "iTC needs some more processing... Waiting even longer..."
          sleep 10
          visit current_url
          sleep 10
        end

        first(".bt-version > a").click

        
        # Inside the build now, enabling the 'Save' button
        save_button = wait_for_elements(".formActionButtons.btn-actions > button").first

        if save_button
          # First, enable the save button
          evaluate_script("$('.formActionButtons.btn-actions > button').removeAttr('disabled')")

          # Maybe we have a 'What to Test' to fill in
          to_test = ENV["DELIVER_WHAT_TO_TEST"]
          if to_test
            text_area = first('span[ng-show="testinfo.data.details[currentLoc].whatsNew.isEditable"] > * > textarea')
            text_area.set to_test if text_area
          end

          save_button.click
        else
          raise "Couldn't find the save button, looks like there is an internet connection problem.".red
        end

        Helper.log.info "Successfully enabled latest beta build.".green

        return true
      rescue => ex
        error_occured(ex)
      end
    end

    # This will choose the latest uploaded build on iTunesConnect as the production one
    # After this method, you still have to call submit_for_review to actually submit the
    # whole update
    # @param app (Deliver::App) the app you want to choose the build for
    # @param version_number (String) the version number as string for 
    def put_build_into_production!(app, version_number)
      begin
        verify_app(app)
        open_app_page(app)

        Helper.log.info("Choosing the latest build on iTunesConnect for release")

        click_on "Prerelease"

        wait_for_preprocessing

        ################# Apple is finished processing the ipa file #################

        Helper.log.info("Apple finally finished processing the ipa file")
        open_app_page(app)

        begin
          first('a', :text => BUTTON_ADD_NEW_BUILD).click
          wait_for_elements(".buildModalList")
          sleep 5
        rescue
          if page.has_content?"Upload Date"
            # That's fine, the ipa was already selected
            return true
          else
            raise "Could not find Build Button. It looks like the ipa file was not properly uploaded."
          end
        end

        if page.all('td', :text => version_number).count > 1
          Helper.log.fatal "There were multiple submitted builds found. Don't know which one to choose. Just choosing the top one for now"
        end

        result = page.first('td', :text => version_number).first(:xpath,"./..").first(:css, ".small").click
        click_on "Done" # Save the modal dialog
        click_on "Save" # on the top right to save everything else

        error = page.has_content?BUTTON_ADD_NEW_BUILD
        raise "Could not put build itself onto production. Try opening '#{current_url}'" if error

        return true
      rescue => ex
        error_occured(ex)
      end
    end

    # Submits the update itself to Apple, this includes the app metadata and the ipa file
    # This can easily cause exceptions, which will be shown on iTC.
    # @param app (Deliver::App) the app you want to submit
    # @param perms (Hash) information about content rights, ...
    def submit_for_review!(app, perms = nil)
      begin
        verify_app(app)
        open_app_page(app)

        Helper.log.info("Submitting app for Review")

        if not page.has_content?BUTTON_STRING_SUBMIT_FOR_REVIEW
          if page.has_content?WAITING_FOR_REVIEW
            Helper.log.info("App is already Waiting For Review")
            return true
          else
            raise "Couldn't find button with name '#{BUTTON_STRING_SUBMIT_FOR_REVIEW}'!"
          end
        end

        click_on BUTTON_STRING_SUBMIT_FOR_REVIEW
        sleep 4

        errors = (all(".pagemessage.error") || []).count > 0
        raise "Some error occured when submitting the app for review: '#{current_url}'" if errors

        wait_for_elements(".savingWrapper.ng-scope.ng-pristine")
        wait_for_elements(".radiostyle")
        sleep 3
        
        if page.has_content?"Content Rights"
          # Looks good.. just a few more steps

          perms ||= {
            export_compliance: {
              encryption_updated: false,
              cryptography_enabled: false,
              is_exempt: false
            },
            third_party_content: {
              contains_third_party_content: false,
              has_rights: false
            },
            advertising_identifier: {
              use_idfa: false,
              serve_advertisement: false,
              attribute_advertisement: false,
              attribute_actions: false,
              limit_ad_tracking: false
            }
          }

          basic = "//*[@itc-radio='submitForReviewAnswers"
          checkbox = "//*[@itc-checkbox='submitForReviewAnswers"

          #####################
          # Export Compliance #
          #####################
          if page.has_content?"Export"
            
            if not perms[:export_compliance][:encryption_updated] and perms[:export_compliance][:cryptography_enabled]
              raise "encryption_updated must be enabled if cryptography_enabled is enabled!"
            end

            begin
              encryption_updated_control = all(:xpath, "#{basic}.exportCompliance.encryptionUpdated.value' and @radio-value='#{perms[:export_compliance][:encryption_updated]}']//input")
              encryption_updated_control[0].trigger('click') if encryption_updated_control.count > 0
              first(:xpath, "#{basic}.exportCompliance.usesEncryption.value' and @radio-value='#{perms[:export_compliance][:cryptography_enabled]}']//input").trigger('click')
              first(:xpath, "#{basic}.exportCompliance.isExempt.value' and @radio-value='#{perms[:export_compliance][:is_exempt]}']//input").trigger('click')
            rescue
            end
          end

          ##################
          # Content Rights #
          ##################
          if page.has_content?"Content Rights"
            if not perms[:third_party_content][:contains_third_party_content] and perms[:third_party_content][:has_rights]
              raise "contains_third_party_content must be enabled if has_rights is enabled".red
            end

            begin
              first(:xpath, "#{basic}.contentRights.containsThirdPartyContent.value' and @radio-value='#{perms[:third_party_content][:contains_third_party_content]}']//input").trigger('click')
              first(:xpath, "#{basic}.contentRights.hasRights.value' and @radio-value='#{perms[:third_party_content][:has_rights]}']//input").trigger('click')
            rescue
            end
          end

          ##########################
          # Advertising Identifier #
          ##########################
          if page.has_content?"Advertising Identifier"
            first(:xpath, "#{basic}.adIdInfo.usesIdfa.value' and @radio-value='#{perms[:advertising_identifier][:use_idfa]}']//a").click rescue nil

            if perms[:advertising_identifier][:use_idfa]
              if perms[:advertising_identifier][:serve_advertisement]
                first(:xpath, "#{checkbox}.adIdInfo.servesAds.value']//a").click
              end
              if perms[:advertising_identifier][:attribute_advertisement]
                first(:xpath, "#{checkbox}.adIdInfo.tracksInstall.value']//a").click
              end
              if perms[:advertising_identifier][:attribute_actions]
                first(:xpath, "#{checkbox}.adIdInfo.tracksAction.value']//a").click
              end
              if perms[:advertising_identifier][:limit_ad_tracking]
                first(:xpath, "#{checkbox}.adIdInfo.limitsTracking.value']//a").click
              end
            end
          end
          

          Helper.log.info("Filled out the export compliance and other information on iTC".green)

          click_on "Submit"
          sleep 5

          if page.has_content?WAITING_FOR_REVIEW
            # Everything worked :)
            Helper.log.info("Successfully submitted App for Review".green)
            return true
          else
            raise "So close, it looks like there went something wrong with the actual deployment. Checkout '#{current_url}'".red
          end
        else
          raise "Something is missing here.".red
        end
        return false
      rescue => ex
        error_occured(ex)
      end
    end

  end
end
