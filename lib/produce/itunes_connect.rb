require 'fastlane_core/itunes_connect/itunes_connect'

module Produce
  # Every method you call here, might take a time
  class ItunesConnect < FastlaneCore::ItunesConnect
    
    APPS_URL = "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app"

    NEW_APP_CLASS = ".new-button.ng-isolate-scope"

    def run(config)
      @config = config
      @full_bundle_identifier = config[:bundle_identifier].gsub('*', config[:bundle_identifier_suffix].to_s)

      if ENV["CREATED_NEW_APP_ID"].to_i > 0
        # We just created this App ID, this takes about 3 minutes to show up on iTunes Connect
        Helper.log.info "Waiting for 3 minutes to make sure, the App ID is synced to iTunes Connect".yellow
        sleep 180

        open_new_app_popup # for some reason, we have to refresh the page twice to get it working
        unless bundle_exist?
          Helper.log.info "Couldn't find new app yet, we're waiting for another 2 minutes.".yellow
          sleep 120
        end
      end

      return create_new_app
    rescue => ex
      error_occured(ex)
    end

    def create_new_app
      if app_exists?
        Helper.log.info "App '#{@config[:app_name]}' exists already, nothing to do on iTunes Connect".green
        # Nothing to do here
      else
        Helper.log.info "Creating new app '#{@config[:app_name]}' on iTunes Connect".green

        initial_create

        initial_pricing

        raise "Something went wrong when creating the new app - it's not listed in the App's list" unless app_exists?

        Helper.log.info "Finished creating new app '#{@config[:app_name]}' on iTunes Connect".green
      end

      return fetch_apple_id
    end

    def fetch_apple_id
      # First try it using the Apple API
      data = JSON.parse(open("https://itunes.apple.com/lookup?bundleId=#{@full_bundle_identifier}").read)

      if data['resultCount'] == 0 or true
        visit APPS_URL
        sleep 10

        first("input[ng-model='searchModel']").set @full_bundle_identifier

        if all("div[bo-bind='app.name']").count == 2
          raise "There were multiple results when looking for the new app. This might be due to having same app identifiers included in each other (see generated screenshots)".red
        end

        app_url = first("a[bo-href='appBundleLink(app.adamId, app.type)']")[:href]
        apple_id = app_url.split('/').last

        Helper.log.info "Found Apple ID #{apple_id}".green
        return apple_id
      else
        return data['results'].first['trackId'] # already in the store
      end
    end

    def initial_create
      open_new_app_popup

      # Fill out the initial information
      wait_for_elements("input[ng-model='createAppDetails.newApp.name.value']").first.set @config[:app_name]
      wait_for_elements("input[ng-model='createAppDetails.versionString.value']").first.set @config[:version]
      wait_for_elements("input[ng-model='createAppDetails.newApp.vendorId.value']").first.set @config[:sku]
      if @config[:company_name] != ''
        Capybara.ignore_hidden_elements = false
        wait_for_elements("input[ng-model='createAppDetails.companyName.value']").first.set @config[:company_name]
        Capybara.ignore_hidden_elements = true
      end

      all(:xpath, "//option[text()='#{@config[:primary_language]}']").first.select_option
      wait_for_elements("option[value='#{@config[:bundle_identifier]}']").first.select_option

      if wildcard_bundle?
        wait_for_elements("input[ng-model='createAppDetails.newApp.bundleIdSuffix.value']").first.set @config[:bundle_identifier_suffix]
      end

      click_on "Create"

      sleep 5 # this usually takes some time

      if all("p[ng-repeat='error in errorText']").count == 1
        raise all("p[ng-repeat='error in errorText']").first.text.to_s.red # an error when creating this app
      end

      wait_for_elements(".language.hasPopOver") # looking good

      Helper.log.info "Successfully created new app '#{@config[:app_name]}' on iTC. Setting up the initial information now.".green
    end

    def initial_pricing
      # It's not important here which is the price set. It will be updated by deliver
      sleep 3
      click_on "Pricing"
      first('#pricingPopup > option[value="0"]').select_option
      first('.saveChangesActionButton').click
    end

    private
      def bundle_exist?
        open_new_app_popup # to get the dropdown of available app identifier, if it's there, the app was not yet created
        sleep 4

        return (all("option[value='#{@config[:bundle_identifier]}']").count == 0)
      end

      def app_exists?
        visit APPS_URL
        sleep 10

        first("input[ng-model='searchModel']").set @full_bundle_identifier

        return (all("div[bo-bind='app.name']").count == 1)
      end

      def wildcard_bundle?
        return @config[:bundle_identifier].end_with?("*")
      end

      def open_new_app_popup
        visit APPS_URL
        sleep 8 # this usually takes some time 

        wait_for_elements(NEW_APP_CLASS).first.click
        wait_for_elements('#new-menu > * > a').first.click # Create a new App

        sleep 5 # this usually takes some time - this is important
        wait_for_elements("input[ng-model='createAppDetails.newApp.name.value']") # finish loading
      end
  end
end
