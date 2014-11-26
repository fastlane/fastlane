require 'deliver/password_manager'
require 'open-uri'
require 'openssl'

require 'capybara'
require 'capybara/poltergeist'

module Sigh
  class DeveloperCenter
    # This error occurs only if there is something wrong with the given login data
    class DeveloperCenterLoginError < StandardError 
    end

    # This error can occur for many reaons. It is
    # usually raised when a UI element could not be found
    class DeveloperCenterGeneralError < StandardError
    end

    # Types of certificates
    APPSTORE = "AppStore"
    ADHOC = "AdHoc"
    DEVELOPMENT = "Development"

    include Capybara::DSL

    DEVELOPER_CENTER_URL = "https://developer.apple.com/devcenter/ios/index.action"
    PROFILES_URL = "https://developer.apple.com/account/ios/profile/profileList.action?type=production"
    PROFILES_URL_DEV = "https://developer.apple.com/account/ios/profile/profileList.action?type=limited"


    def initialize
      FileUtils.mkdir_p TMP_FOLDER

      DependencyChecker.check_dependencies
      
      Capybara.run_server = false
      Capybara.default_driver = :poltergeist
      Capybara.javascript_driver = :poltergeist
      Capybara.current_driver = :poltergeist
      Capybara.app_host = DEVELOPER_CENTER_URL

      # Since Apple has some SSL errors, we have to configure the client properly:
      # https://github.com/ariya/phantomjs/issues/11239
      Capybara.register_driver :poltergeist do |a|
        conf = ['--debug=no', '--ignore-ssl-errors=yes', '--ssl-protocol=TLSv1']
        Capybara::Poltergeist::Driver.new(a, {
          phantomjs_options: conf,
          phantomjs_logger: File.open("#{TMP_FOLDER}/poltergeist_log.txt", "a"),
          js_errors: false
        })
      end

      page.driver.headers = { "Accept-Language" => "en" }

      self.login
    end

    # Loggs in a user with the given login data on the Dev Center Frontend.
    # You don't need to pass a username and password. It will
    # Automatically be fetched using the {Deliver::PasswordManager}.
    # This method will also automatically be called when triggering other 
    # actions like {#open_app_page}
    # @param user (String) (optional) The username/email address
    # @param password (String) (optional) The password
    # @return (bool) true if everything worked fine
    # @raise [DeveloperCenterGeneralError] General error while executing 
    #  this action
    # @raise [DeveloperCenterLoginError] Login data is wrong
    def login(user = nil, password = nil)
      begin
        Helper.log.info "Login into iOS Developer Center"

        user ||= Deliver::PasswordManager.shared_manager.username
        password ||= Deliver::PasswordManager.shared_manager.password

        result = visit PROFILES_URL
        raise "Could not open Developer Center" unless result['status'] == 'success'

        if page.has_content?"Member Center"
          # Already logged in
          return true
        end

        (wait_for_elements(".button.blue").first.click rescue nil) # maybe already logged in

        (wait_for_elements('#accountpassword') rescue nil) # when the user is already logged in, this will raise an exception

        if page.has_content?"Member Center"
          # Already logged in
          return true
        end

        fill_in "accountname", with: user
        fill_in "accountpassword", with: password

        begin
          all(".button.large.blue.signin-button").first.click

          wait_for_elements('.ios.profiles.gridList')
          visit PROFILES_URL # again, since after the login, the dev center loses the production GET value
        rescue Exception => ex
          Helper.log.debug ex
          raise DeveloperCenterLoginError.new("Error logging in user #{user} with the given password. Make sure you entered them correctly.")
        end

        Helper.log.info "Login successful"
        
        true
      rescue Exception => ex
        error_occured(ex)
      end
    end

    def run(app_identifier, type, cert_name = nil)
      cert = maintain_app_certificate(app_identifier, type)

      cert_name ||= "#{type}_#{app_identifier}.mobileprovision" # default name
      cert_name += '.mobileprovision' unless cert_name.include?'mobileprovision'

      output_path = TMP_FOLDER + cert_name
      File.write(output_path, cert)

      return output_path
    end

    def maintain_app_certificate(app_identifier, type)
      begin
        if type == DEVELOPMENT 
          visit PROFILES_URL_DEV
        else
          visit PROFILES_URL
        end

        @list_certs_url = page.html.match(/var profileDataURL = "(.*)"/)[1]
        # list_certs_url will look like this: "https://developer.apple.com/services-account/..../account/ios/profile/listProvisioningProfiles.action?content-type=application/x-www-form-urlencoded&accept=application/json&requestId=id&userLocale=en_US&teamId=xy&includeInactiveProfiles=true&onlyCountLists=true"
        Helper.log.info "Fetching all available provisioning profiles..."

        certs = post_ajax(@list_certs_url)

        Helper.log.info "Checking if profile is available. (#{certs['provisioningProfiles'].count} profiles found)"
        certs['provisioningProfiles'].each do |current_cert|
          next if type == DEVELOPMENT and current_cert['type'] != "iOS Development"
          next if type != DEVELOPMENT and current_cert['type'] != 'iOS Distribution'
          
          details = profile_details(current_cert['provisioningProfileId'])

          if details['provisioningProfile']['appId']['identifier'] == app_identifier
            if type == APPSTORE and details['provisioningProfile']['deviceCount'] > 0
              next # that's an Ad Hoc profile. I didn't find a better way to detect if it's one ... skipping it
            end
            if type != APPSTORE and details['provisioningProfile']['deviceCount'] == 0
              next # that's an App Store profile ... skipping it
            end

            # We found the correct certificate
            if current_cert['status'] == 'Active'
              return download_profile(details['provisioningProfile']['provisioningProfileId']) # this one is already finished. Just download it.
            elsif ['Expired', 'Invalid'].include?current_cert['status']
              renew_profile(current_cert['provisioningProfileId'], type) # This one needs to be renewed
              return maintain_app_certificate(app_identifier, type) # recursive
            end

            break
          end
        end

        Helper.log.info "Could not find existing profile. Trying to create a new one."
        # Certificate does not exist yet, we need to create a new one
        create_profile(app_identifier, type)
        # After creating the profile, we need to download it
        return maintain_app_certificate(app_identifier, type) # recursive

      rescue Exception => ex
        error_occured(ex)
      end
    end

    def create_profile(app_identifier, type)
      Helper.log.info "Creating new profile for app '#{app_identifier}' for type '#{type}'.".yellow
      certificate = code_signing_certificate(type)

      create_url = "https://developer.apple.com/account/ios/profile/profileCreate.action"
      visit create_url

      # 1) Select the profile type (AppStore, Adhoc)
      wait_for_elements('#type-production')
      value = 'store'
      value = 'limited' if type == DEVELOPMENT
      value = 'adhoc' if type == ADHOC

      first(:xpath, "//input[@type='radio' and @value='#{value}']").click
      click_next

      # 2) Select the App ID
      while not page.has_content?"Select App ID" do sleep 1 end
      # example: <option value="RGAWZGXSY4">ABP (5A997XSHK2.net.sunapps.34)</option>
      first(:xpath, "//option[contains(text(), '.#{app_identifier})')]").select_option
      click_next

      # 3) Select the certificate
      while not page.has_content?"Select certificates" do sleep 1 end
      sleep 3
      Helper.log.info "Using certificate ID '#{certificate['certificateId']}' from '#{certificate['ownerName']}'"

      # example: <input type="radio" name="certificateIds" class="validate" value="[XC5PH8D47H]"> (production)
      id = certificate["certificateId"]
      certs = all(:xpath, "//input[@type='radio' and @value='[#{id}]']") if type != DEVELOPMENT # production uses radio and has a [] around the value
      certs = all(:xpath, "//input[@type='checkbox' and @value='#{id}']") if type == DEVELOPMENT # development uses a checkbox and has no [] around the value
      if certs.count != 1
        Helper.log.info "Looking for certificate: #{certificate}. Found: #{certs.count}"
        raise "Could not find certificate in the list of available certificates."
      end
      certs.first.click
      click_next

      if type != APPSTORE
        # 4) Devices selection
        wait_for_elements('.selectAll.column')
        sleep 3

        first(:xpath, "//div[@class='selectAll column']/input").click # select all the devices
        click_next
      end

      # 5) Choose a profile name
      wait_for_elements('.distributionType')
      profile_name = [app_identifier, type].join(' ')
      fill_in "provisioningProfileName", with: profile_name
      click_next
      wait_for_elements('.row-details')
    end

    def renew_profile(profile_id, type)
      certificate = code_signing_certificate type

      details_url = "https://developer.apple.com/account/ios/profile/profileEdit.action?type=&provisioningProfileId=#{profile_id}"
      Helper.log.info "Renewing provisioning profile '#{profile_id}' using URL '#{details_url}'"
      visit details_url

      Helper.log.info "Using certificate ID '#{certificate['certificateId']}' from '#{certificate['ownerName']}'"
      wait_for_elements('.selectCertificates')

      certs = all(:xpath, "//input[@type='radio' and @value='#{certificate["certificateId"]}']")
      if certs.count == 1
        certs.first.click
        click_next

        wait_for_elements('.row-details')
        click_on "Done"
      else
        Helper.log.info "Looking for certificate: #{certificate}. Found: #{certs}"
        raise "Could not find certificate in the list of available certificates."
      end
    end

    def download_profile(profile_id)
      download_cert_url = "/account/ios/profile/profileContentDownload.action?displayId=#{profile_id}"

      return download_file(download_cert_url)
    end


    private
      def profile_details(profile_id)
        # We need to build the URL to get the App ID for a specific certificate
        current_profile_url = @list_certs_url.gsub('listProvisioningProfiles', 'getProvisioningProfile')
        current_profile_url += "&provisioningProfileId=#{profile_id}"
        # Helper.log.debug "Fetching URL: '#{current_profile_url}'"

        result = post_ajax(current_profile_url)
        # Example response, see bottom of file

        if result['resultCode'] == 0
          return result
        else
          raise "Error fetching details for provisioning profile '#{profile_id}'".red
        end
      end

      # Returns a hash, that contains information about the iOS certificate
      # @example
        # {"certRequestId"=>"B23Q2P396B",
        # "name"=>"SunApps GmbH",
        # "statusString"=>"Issued",
        # "expirationDate"=>"2015-11-25T22:45:50Z",
        # "expirationDateString"=>"Nov 25, 2015",
        # "ownerType"=>"team",
        # "ownerName"=>"SunApps GmbH",
        # "ownerId"=>"....",
        # "canDownload"=>true,
        # "canRevoke"=>true,
        # "certificateId"=>"....",
        # "certificateStatusCode"=>0,
        # "certRequestStatusCode"=>4,
        # "certificateTypeDisplayId"=>"...",
        # "serialNum"=>"....",
        # "typeString"=>"iOS Distribution"},
      def code_signing_certificate(type)
        certs_url = "https://developer.apple.com/account/ios/certificate/certificateList.action?type="
        certs_url << "distribution" if type != DEVELOPMENT
        certs_url << "development" if type == DEVELOPMENT
        visit certs_url

        certificateDataURL = page.html.match(/var certificateDataURL = "(.*)"/)[1]
        certificateRequestTypes = page.html.match(/var certificateRequestTypes = "(.*)"/)[1]
        certificateStatuses = page.html.match(/var certificateStatuses = "(.*)"/)[1]
        url = [certificateDataURL, certificateRequestTypes, certificateStatuses].join('')

        # https://developer.apple.com/services-account/.../account/ios/certificate/listCertRequests.action?content-type=application/x-www-form-urlencoded&accept=application/json&requestId=...&userLocale=en_US&teamId=...&types=...&status=4&certificateStatus=0&type=distribution

        certs = post_ajax(url)['certRequests']
        certs.each do |current_cert|
          if type != DEVELOPMENT and current_cert['typeString'] == 'iOS Distribution' 
            # The other profiles are push profiles
            # We only care about the distribution profile
            return current_cert # mostly we only care about the 'certificateId'
          elsif type == DEVELOPMENT and current_cert['typeString'] == 'iOS Development' 
            return current_cert # mostly we only care about the 'certificateId'
          end
        end

        raise "Could not find a Certificate. Please open #{current_url} and make sure you have a signing profile created.".red
      end

      # Download a file from the dev center, by using a HTTP client. This will return the content of the file
      def download_file(url)
        Helper.log.info "Downloading profile..."
        host = Capybara.current_session.current_host
        url = [host, url].join('')

        myacinfo = page.driver.cookies['myacinfo'].value # some Apple magic, which is required for the profile download
        data = open(url, {'Cookie' => "myacinfo=#{myacinfo}"}).read

        raise "Something went wrong when downloading the file from the Dev Center" unless data
        Helper.log.info "Successfully downloaded provisioning profile"
        return data
      end

      def post_ajax(url)
        JSON.parse(page.evaluate_script("$.ajax({type: 'POST', url: '#{url}', async: false})")['responseText'])
      end

      def click_next
        wait_for_elements('.button.small.blue.right.submit').last.click
      end

      def error_occured(ex)
        snap
        raise ex # re-raise the error after saving the snapshot
      end

      def snap
        path = "Error#{Time.now.to_i}.png"
        save_screenshot(path, :full => true)
        system("open '#{path}'")
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
            raise DeveloperCenterGeneralError.new("Couldn't find element '#{name}' after waiting for quite some time")
          end
        end
        return results
      end
  end
end




# Example response 1)
# => {"resultCode"=>0,
#    "protocolVersion"=>"....",
#    "isAdmin"=>true,
#    "isMember"=>false,
#    "isAgent"=>true,
#    "pageNumber"=>nil,
#    "pageSize"=>nil,
#    "totalRecords"=>nil,
#    "provisioningProfile"=>
#     {"provisioningProfileId"=>"....",
#      "name"=>"Gut Altentann Development",
#      "status"=>"Active",
#      "type"=>"iOS Development",
#      "distributionMethod"=>"limited",
#      "proProPlatform"=>"ios",
#      "version"=>"ProvisioningProfilev1",
#      "dateExpire"=>"2015-02-22",
#      "managingApp"=>nil,
#      "appId"=>
#       {"appIdId"=>".....",
#        "name"=>"SunApps",
#        "appIdPlatform"=>"ios",
#        "prefix"=>"....",
#        "identifier"=>"net.sunapps.123",
#        "isWildCard"=>true,
#        "isDuplicate"=>false,
#        "features"=>
#         {"push"=>false,
#          "inAppPurchase"=>false,
#          "gameCenter"=>false,
#          "passbook"=>false,
#          "dataProtection"=>"",
#          "homeKit"=>false,
#          "cloudKitVersion"=>1,
#          "iCloud"=>false,
#          "LPLF93JG7M"=>false,
#          "WC421J6T7P"=>false},
#        "enabledFeatures"=>[],
#        "isDevPushEnabled"=>false,
#        "isProdPushEnabled"=>false,
#        "associatedApplicationGroupsCount"=>nil,
#        "associatedCloudContainersCount"=>nil,
#        "associatedIdentifiersCount"=>nil},
#      "appIdId"=>".....",
#      "deviceCount"=>8,
#      "certificateCount"=>1,
#      "UUID"=>"F670D427-2D0E-4782-8171-....."}}
