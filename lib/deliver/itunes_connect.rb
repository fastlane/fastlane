require 'deliver/password_manager'

require 'capybara'
require 'capybara/poltergeist'
require 'security'


module Deliver
  # Everything that can't be achived using the {Deliver::ItunesTransporter}
  # will be scripted using the iTunesConnect frontend.
  # 
  # Every method you call here, might take a time
  class ItunesConnect
    # This error occurs only if there is something wrong with the given login data
    class ItunesConnectLoginError < StandardError 
    end

    # This error can occur for many reaons. It is
    # usually raised when a UI element could not be found
    class ItunesConnectGeneralError < StandardError
    end

    include Capybara::DSL

    ITUNESCONNECT_URL = "https://itunesconnect.apple.com/"
    APP_DETAILS_URL = "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/[[app_id]]"

    BUTTON_STRING_NEW_VERSION = "New Version"
    BUTTON_STRING_SUBMIT_FOR_REVIEW = "Submit for Review"
    BUTTON_ADD_NEW_BUILD = 'Click + to add a build before you submit your app.'

    WAITING_FOR_REVIEW = "Waiting For Review"
    PROCESSING_TEXT = "Processing"
    
    def initialize
      super

      DependencyChecker.check_for_brew
      
      Capybara.run_server = false
      Capybara.default_driver = :poltergeist
      Capybara.javascript_driver = :poltergeist
      Capybara.current_driver = :poltergeist
      Capybara.app_host = ITUNESCONNECT_URL

      # Since Apple has some SSL errors, we have to configure the client properly:
      # https://github.com/ariya/phantomjs/issues/11239
      Capybara.register_driver :poltergeist do |a|
        conf = ['--debug=no', '--ignore-ssl-errors=yes', '--ssl-protocol=TLSv1']
        Capybara::Poltergeist::Driver.new(a, {
          phantomjs_options: conf,
          phantomjs_logger: File.open("/tmp/poltergeist_log.txt", "a"),
        })
      end

      self.login
    end

    # Loggs in a user with the given login data on the iTC Frontend.
    # You don't need to pass a username and password. It will
    # Automatically be fetched using the {Deliver::PasswordManager}.
    # This method will also automatically be called when triggering other 
    # actions like {#open_app_page}
    # @param user (String) (optional) The username/email address
    # @param password (String) (optional) The password
    # @return (bool) true if everything worked fine
    # @raise [ItunesConnectGeneralError] General error while executing 
    #  this action
    # @raise [ItunesConnectLoginError] Login data is wrong
    def login(user = nil, password = nil)
      begin
        Helper.log.info "Logging into iTunesConnect"

        user ||= PasswordManager.new.username
        password ||= PasswordManager.new.password

        result = visit ITUNESCONNECT_URL
        raise "Could not open iTunesConnect" unless result['status'] == 'success'

        if page.has_content?"My Apps"
          # Already logged in
          return true
        end

        fill_in "accountname", with: user
        fill_in "accountpassword", with: password

        begin
          wait_for_elements(".enabled").first.click
          wait_for_elements('.ng-scope.managedWidth')
        rescue
          ItunesConnectLoginError.new("Error logging in user #{user} with the given password. Make sure you set them correctly")
        end

        Helper.log.info "Successfully logged into iTunesConnect"

        true
      rescue Exception => ex
        error_occured(ex)
      end
    end

    # Opens the app details page of the given app.
    # @param app (Deliver::App) the app that should be opened
    # @return (bool) true if everything worked fine
    # @raise [ItunesConnectGeneralError] General error while executing 
    #  this action
    # @raise [ItunesConnectLoginError] Login data is wrong
    def open_app_page(app)
      begin
        verify_app(app)

        Helper.log.info "Opening detail page for app #{app}"

        visit APP_DETAILS_URL.gsub("[[app_id]]", app.apple_id.to_s)

        wait_for_elements('.page-subnav')
        sleep 3

        true
      rescue Exception => ex
        error_occured(ex)
      end
    end

    # This method will fetch the current status ({Deliver::App::AppStatus})
    # of your app and return it. This method uses a headless browser
    # under the hood, so it might take some time until you get the result
    # @param app (Deliver::App) the app you want this information from
    # @raise [ItunesConnectGeneralError] General error while executing 
    #  this action
    # @raise [ItunesConnectLoginError] Login data is wrong
    def get_app_status(app)
      begin
        verify_app(app)

        open_app_page(app)

        if page.has_content?WAITING_FOR_REVIEW
          # That's either Upload Received or Waiting for Review
          if page.has_content?"To submit a new build, you must remove this version from review"
            return App::AppStatus::WAITING_FOR_REVIEW
          else
            return App::AppStatus::UPLOAD_RECEIVED
          end
        elsif page.has_content?BUTTON_STRING_NEW_VERSION
          return App::AppStatus::READY_FOR_SALE
        elsif page.has_content?BUTTON_STRING_SUBMIT_FOR_REVIEW
          return App::AppStatus::PREPARE_FOR_SUBMISSION
        else
          raise "App status not yet implemented"
        end
      rescue Exception => ex
        error_occured(ex)
      end
    end

    # This method will fetch the version number of the currently live version
    # of your app and return it. This method uses a headless browser
    # under the hood, so it might take some time until you get the result
    # @param app (Deliver::App) the app you want this information from
    # @raise [ItunesConnectGeneralError] General error while executing 
    #  this action
    # @raise [ItunesConnectLoginError] Login data is wrong
    def get_live_version(app)
      begin
        verify_app(app)

        open_app_page(app)

        return first(".status.ready").text.split(" ").first
      rescue Exception => ex
        error_occured(ex)
      end
    end



    # Constructive/Destructive Methods

    # This method creates a new version of your app using the
    # iTunesConnect frontend. This will happen directly after calling
    # this method. 
    # @param app (Deliver::App) the app you want to modify
    # @param version_number (String) the version number as string for 
    # the new version that should be created
    def create_new_version!(app, version_number)
      begin
        current_version = get_live_version(app)

        verify_app(app)
        open_app_page(app)

        if page.has_content?BUTTON_STRING_NEW_VERSION

          if current_version == version_number
            # This means, this version is already live on the App Store
            raise "Version #{version_number} is already created, submitted and released on iTC. Please verify you're using a new version number."
          end

          click_on BUTTON_STRING_NEW_VERSION

          Helper.log.info "Creating a new version (#{version_number})"
          
          all(".fullWidth.nobottom.ng-isolate-scope.ng-pristine").last.set(version_number.to_s)
          click_on "Create"

          while not page.has_content?"Prepare for Submission"
            sleep 1
            Helper.log.debug("Waiting for 'Prepare for Submission'")
          end
        else
          Helper.log.warn "Can not create version #{version_number} on iTunesConnect. Maybe it was already created."
          Helper.log.info "Check out '#{current_url}' what's the latest version."

          created_version = first(".status.waiting").text.split(" ").first
          if created_version != version_number
            raise "Some other version ('#{created_version}') was created instead of the one you defined ('#{version_number}')"
          end
        end

        true
      rescue Exception => ex
        error_occured(ex)
      end
    end

    def wait_for_preprocessing
      started = Time.now

      # Wait, while iTunesConnect is processing the uploaded file
      while page.has_content?"Uploaded"
        # iTunesConnect is super slow... so we have to wait...
        Helper.log.info("Sorry, we have to wait for iTunesConnect, since it's still processing the uploaded ipa file\n" + 
          "If this takes longer than 45 minutes, you have to re-upload the ipa file again.\n" + 
          "You can always open the browser page yourself: '#{current_url}'\n" +
          "Passed time: ~#{((Time.now - started) / 60.0).to_i} minute(s)")
        sleep 10
        visit current_url
      end
    end

    # This will put the latest uploaded build as a new beta build
    def put_build_into_beta_testing!(app, version_number)
      begin
        verify_app(app)
        open_app_page(app)

        Helper.log.info("Choosing the latest build on iTunesConnect for beta distribution")

        click_on "Prerelease"

        wait_for_preprocessing

        if all(".switcher.ng-binding").count == 0
          raise "Could not find beta build on '#{current_url}'. Make sure it is available there"
        end

        if first(".switcher.ng-binding")['class'].include?"checked"
          Helper.log.warn("Beta Build seems to be already active. Take a look at '#{current_url}'")
          return true
        end

        first(".switcher.ng-binding").click
        if page.has_content?"Are you sure you want to start testing"
          click_on "Start"
        end

        # TODO: Check if everything has worked properly

        return true
      rescue Exception => ex
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
          sleep 1
        rescue
          if page.has_content?"Upload Date"
            # That's fine, the ipa was already selected
            return true
          else
            raise "Could not find Build Button. It looks like the ipa file was not properly uploaded."
          end
        end

        if page.all('td', :text => version_number).count > 1
          error_text = "There were multiple submitted builds found. Don't know which one to choose.\n" + 
            "Open '#{current_url}' in your browser, remove all builds and run this script again"
          raise error_text
        end

        result = page.first('td', :text => version_number).first(:xpath,"./..").first(:css, ".small").click
        click_on "Done" # Save the modal dialog
        click_on "Save" # on the top right to save everything else

        error = page.has_content?BUTTON_ADD_NEW_BUILD
        raise "Could not put build itself onto production. Try opening '#{current_url}'" if error

        return true
      rescue Exception => ex
        error_occured(ex)
      end
    end

    # Submits the update itself to Apple, this includes the app metadata and the ipa file
    # This can easily cause exceptions, which will be shown on iTC.
    # @param app (Deliver::App) the app you want to submit
    def submit_for_review!(app)
      begin
        verify_app(app)
        open_app_page(app)

        Helper.log.info("Submitting app for Review")

        if not page.has_content?BUTTON_STRING_SUBMIT_FOR_REVIEW
          if page.has_content?WAITING_FOR_REVIEW
            Helper.log.info("App is already Waiting For Review")
            return true
          else
            raise "Couldn't find button with name '#{BUTTON_STRING_SUBMIT_FOR_REVIEW}'"
          end
        end

        click_on BUTTON_STRING_SUBMIT_FOR_REVIEW
        sleep 4

        errors = (all(".pagemessage.error") || []).count > 0
        raise "Some error occured when submitting the app for review: '#{current_url}'" if errors


        wait_for_elements(".savingWrapper.ng-scope.ng-pristine.ng-valid.ng-valid-required")
        if page.has_content?"Content Rights"
          # Looks good.. just a few more steps

          perms = {
            export_compliance: false,
            third_party_content: false,
            advertising_identifier: false
          }

          basic = "//*[@itc-radio='submitForReviewAnswers"

          #####################
          # Export Compliance #
          #####################
          if page.has_content?"Export"
            all(:xpath, "#{basic}.exportCompliance.encryptionUpdated.value' and @radio-value='#{perms[:export_compliance]}']").first.click
            if perms[:export_compliance]
              raise "Sorry, that's not supported yet" # TODO
            end
          end

          ##################
          # Content Rights #
          ##################
          if page.has_content?"Content Rights"
            all(:xpath, "#{basic}.contentRights.containsThirdPartyContent.value' and @radio-value='#{perms[:third_party_content]}']").first.click
            if perms[:third_party_content]
              raise "Sorry, that's not supported yet" # TODO
            end
          end

          ##########################
          # Advertising Identifier #
          ##########################
          if page.has_content?"Advertising Identifier"
            all(:xpath, "#{basic}.adIdInfo.usesIdfa.value' and @radio-value='#{perms[:advertising_identifier]}']").first.click
            if perms[:advertising_identifier]
              raise "Sorry, that's not supported yet" # TODO
            end
          end
          

          Helper.log.info("Filled out the export compliance and other information on iTC")

          click_on "Submit"
          sleep 5

          if page.has_content?WAITING_FOR_REVIEW
            # Everything worked :)
            Helper.log.info("Successfully submitted App for Review".green)
            return true
          else
            raise "So close, it looks like there went something wrong with the actual deployment. Checkout '#{current_url}'"
          end
        else
          raise "Something is missing here."
        end
        return false
      rescue Exception => ex
        error_occured(ex)
      end
    end


    private
      def verify_app(app)
        raise ItunesConnectGeneralError.new("No valid Deliver::App given") unless app.kind_of?Deliver::App
        raise ItunesConnectGeneralError.new("App is missing information") unless (app.apple_id || '').to_s.length > 5
      end

      def error_occured(ex)
        path = "Error#{Time.now.to_i}.png"
        save_screenshot(path, :full => true)
        system("open '#{path}'")
        raise ex # re-raise the error after saving the snapshot
      end

      def wait_for_elements(name)
        counter = 0
        results = all(name)
        while results.count == 0      
          # Helper.log.debug "Waiting for #{name}"
          sleep 0.2

          results = all(name)

          counter += 1
          if counter > 100
            Helper.log.debug page.html
            Helper.log.debug caller
            raise ItunesConnectGeneralError.new("Couldn't find element '#{name}' after waiting for quite some time")
          end
        end
        return results
      end
  end
end