require 'credentials_manager/password_manager'
require 'open-uri'
require 'openssl'

require 'capybara'
require 'capybara/poltergeist'
require 'phantomjs/poltergeist'

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
          phantomjs: Phantomjs.path,
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
    # Automatically be fetched using the {CredentialsManager::PasswordManager}.
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

        user ||= CredentialsManager::PasswordManager.shared_manager.username
        password ||= CredentialsManager::PasswordManager.shared_manager.password

        result = visit PROFILES_URL
        raise "Could not open Developer Center" unless result['status'] == 'success'

        # Already logged in
        return true if page.has_content? "Member Center"

        (wait_for_elements(".button.blue").first.click rescue nil) # maybe already logged in

        (wait_for_elements('#accountpassword') rescue nil) # when the user is already logged in, this will raise an exception

        # Already logged in
        return true if page.has_content? "Member Center"

        fill_in "accountname", with: user
        fill_in "accountpassword", with: password

        all(".button.large.blue.signin-button").first.click

        begin
          # If the user is not on multiple teams
          select_team if page.has_content? "Select Team"
        rescue => ex
          Helper.log.debug ex
          raise DeveloperCenterLoginError.new("Error loggin in user #{user}. User is on multiple teams and we were unable to correctly retrieve them.")
        end

        begin
          wait_for_elements('.ios.profiles.gridList')
          visit PROFILES_URL # again, since after the login, the dev center loses the production GET value
        rescue => ex
          Helper.log.debug ex
          if page.has_content?"Getting Started"
            raise "There was no valid signing certificate found. Please log in and follow the 'Getting Started guide' on '#{current_url}'".red
          else
            raise DeveloperCenterLoginError.new("Error logging in user #{user} with the given password. Make sure you entered them correctly.")
          end
        end


        Helper.log.info "Login successful"
        
        true
      rescue => ex
        error_occured(ex)
      end
    end


    def select_team
      team_id = ENV["SIGH_TEAM_ID"]
      team_id = nil if team_id.to_s.length == 0

      unless team_id
        Helper.log.info "You can store you preferred team using the environment variable `SIGH_TEAM_ID`".green
        Helper.log.info "Your ID belongs to the following teams:".green
      end
      
      available_options = []

      teams = find("div.input").all('.team-value') # Grab all the teams data
      teams.each_with_index do |val, index|
        current_team_id = '"' + val.find("input").value + '"'
        team_text = val.find(".label-primary").text
        description_text = val.find(".label-secondary").text
        description_text = "(#{description_text})" unless description_text.empty? # Include the team description if any
        index_text = (index + 1).to_s + "."

        available_options << [index_text, current_team_id, team_text, description_text].join(" ")
      end

      unless team_id
        puts available_options.join("\n").green
        team_index = ask("Please select the team number you would like to access: ".green)
        team_id = teams[team_index.to_i - 1].find(".radio").value
      end

      team_button = first(:xpath, "//input[@type='radio' and @value='#{team_id}']") # Select the desired team
      if team_button
        team_button.click
      else
        Helper.log.fatal "Could not find given Team. Available options: ".red
        puts available_options.join("\n").yellow
        raise DeveloperCenterLoginError.new("Error finding given team #{team_id}.".red)
      end

      all(".button.large.blue.submit").first.click

      result = visit PROFILES_URL
      raise "Could not open Developer Center" unless result['status'] == 'success'
    end

    def run(app_identifier, type, cert_name = nil, force = false, cert_date = nil)
      cert = maintain_app_certificate(app_identifier, type, force, cert_date)

      type_name = type
      type_name = "Distribution" if type == APPSTORE # both enterprise and App Store
      cert_name ||= "#{type_name}_#{app_identifier}.mobileprovision" # default name
      cert_name += '.mobileprovision' unless cert_name.include?'mobileprovision'

      output_path = TMP_FOLDER + cert_name
      File.write(output_path, cert)

      return output_path
    end

    def maintain_app_certificate(app_identifier, type, force, cert_date)
      begin
        if type == DEVELOPMENT 
          visit PROFILES_URL_DEV
        else
          visit PROFILES_URL
        end

        @list_certs_url = wait_for_variable('profileDataURL')
        # list_certs_url will look like this: "https://developer.apple.com/services-account/..../account/ios/profile/listProvisioningProfiles.action?content-type=application/x-www-form-urlencoded&accept=application/json&requestId=id&userLocale=en_US&teamId=xy&includeInactiveProfiles=true&onlyCountLists=true"
        Helper.log.info "Fetching all available provisioning profiles..."

        certs = post_ajax(@list_certs_url)

        Helper.log.info "Checking if profile is available. (#{certs['provisioningProfiles'].count} profiles found)"
        required_cert_types = type == DEVELOPMENT ? ['iOS Development'] : ['iOS Distribution', 'iOS UniversalDistribution']
        certs['provisioningProfiles'].each do |current_cert|
          next unless required_cert_types.include?(current_cert['type'])
          
          details = profile_details(current_cert['provisioningProfileId'])

          if details['provisioningProfile']['appId']['identifier'] == app_identifier
            # that's an Ad Hoc profile. I didn't find a better way to detect if it's one ... skipping it
            next if type == APPSTORE && details['provisioningProfile']['deviceCount'] > 0

            # that's an App Store profile ... skipping it
            next if type != APPSTORE && details['provisioningProfile']['deviceCount'] == 0

            # We found the correct certificate
            if force && type != DEVELOPMENT
              provisioningProfileId = current_cert['provisioningProfileId']
              renew_profile(provisioningProfileId, type, cert_date) # This one needs to be forcefully renewed
              return maintain_app_certificate(app_identifier, type, false, cert_date) # recursive
            elsif current_cert['status'] == 'Active'
              return download_profile(details['provisioningProfile']['provisioningProfileId']) # this one is already finished. Just download it.
            elsif ['Expired', 'Invalid'].include? current_cert['status']
              renew_profile(current_cert['provisioningProfileId'], type, cert_date) # This one needs to be renewed
              return maintain_app_certificate(app_identifier, type, false, cert_date) # recursive
            end

            break
          end
        end

        Helper.log.info "Could not find existing profile. Trying to create a new one."
        # Certificate does not exist yet, we need to create a new one
        create_profile(app_identifier, type, cert_date)
        # After creating the profile, we need to download it
        return maintain_app_certificate(app_identifier, type, false, cert_date) # recursive

      rescue => ex
        error_occured(ex)
      end
    end

    def create_profile(app_identifier, type, cert_date)
      Helper.log.info "Creating new profile for app '#{app_identifier}' for type '#{type}'.".yellow
      certificates = code_signing_certificates(type, cert_date)

      create_url = "https://developer.apple.com/account/ios/profile/profileCreate.action"
      visit create_url

      # 1) Select the profile type (AppStore, Adhoc)
      enterprise = false

      begin
        wait_for_elements('#type-production')
      rescue => ex
        wait_for_elements('#type-inhouse') # enterprise accounts
        enterprise = true
      end

      value = enterprise ? 'inhouse' : 'store'
      value = 'limited' if type == DEVELOPMENT
      value = 'adhoc' if type == ADHOC

      first(:xpath, "//input[@type='radio' and @value='#{value}']").click
      click_next

      # 2) Select the App ID
      sleep 1 while !page.has_content? "Select App ID"
      # example: <option value="RGAWZGXSY4">ABP (5A997XSHK2.net.sunapps.34)</option>
      identifiers = all(:xpath, "//option[contains(text(), '.#{app_identifier})')]")
      if identifiers.count == 0
        puts "Couldn't find App ID '#{app_identifier}'\nonly found the following bundle identifiers:".red
        all(:xpath, "//option").each do |current|
          puts "\t- #{current.text}".yellow
        end
        raise "Could not find Apple ID '#{app_identifier}'.".red
      else
        identifiers.first.select_option
      end
      click_next

      # 3) Select the certificate
      sleep 1 while !page.has_content? "Select certificates"
      sleep 3
      Helper.log.info "Using certificates: #{certificates.map { |c| "#{c['ownerName']} (#{c['certificateId']})" } }"

      # example: <input type="radio" name="certificateIds" class="validate" value="[XC5PH8D47H]"> (production)

      clicked = false
      certificates.each do |cert|
        cert_id = cert['certificateId']
        input = if type == DEVELOPMENT
          # development uses a checkbox and has no [] around the value
          first(:xpath, "//input[@type='checkbox' and @value='#{cert_id}']")
        else
          break if clicked
          # production uses radio and has a [] around the value
          first(:xpath, "//input[@type='radio' and @value='[#{cert_id}]']")
        end
        if input
          input.click
          clicked = true
        end
      end

      if !clicked
        raise "Could not find certificate in the list of available certificates."
      end
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

    def renew_profile(profile_id, type, cert_date)
      certificate = code_signing_certificates(type, cert_date).first

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
        Helper.log.info "Looking for certificate: #{certificate}."
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

      # Returns a array of hashs, that contains information about the iOS certificate
      # @example
        # [{"certRequestId"=>"B23Q2P396B",
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
        # {another sertificate...}]
      def code_signing_certificates(type, cert_date)
        certs_url = "https://developer.apple.com/account/ios/certificate/certificateList.action?type="
        certs_url << (type == DEVELOPMENT ? 'development' : 'distribution')
        visit certs_url

        certificateDataURL = wait_for_variable('certificateDataURL')
        certificateRequestTypes = wait_for_variable('certificateRequestTypes')
        certificateStatuses = wait_for_variable('certificateStatuses')

        url = [certificateDataURL, certificateRequestTypes, certificateStatuses].join('')

        # https://developer.apple.com/services-account/.../account/ios/certificate/listCertRequests.action?content-type=application/x-www-form-urlencoded&accept=application/json&requestId=...&userLocale=en_US&teamId=...&types=...&status=4&certificateStatus=0&type=distribution

        certs = post_ajax(url)['certRequests']

        ret_certs = []
        certificate_name = ENV['SIGH_CERTIFICATE']

        # The other profiles are push profiles
        certificate_type = type == DEVELOPMENT ? 'iOS Development' : 'iOS Distribution'
        
        # New profiles first
        certs.sort! do |a, b|
          Time.parse(b['expirationDate']) <=> Time.parse(a['expirationDate'])
        end

        certs.each do |current_cert|
          next unless current_cert['typeString'] == certificate_type

          if cert_date || certificate_name
            if current_cert['expirationDateString'] == cert_date
              Helper.log.info "Certificate ID '#{current_cert['certificateId']}' with expiry date '#{current_cert['expirationDateString']}' located"
              ret_certs << current_cert
            end
            if current_cert['name'] == certificate_name
              Helper.log.info "Certificate ID '#{current_cert['certificateId']}' with name '#{certificate_name}' located"
              ret_certs << current_cert
            end
          else
            ret_certs << current_cert
          end
        end

        return ret_certs unless ret_certs.empty?

        predicates = []
        predicates << "name: #{certificate_name}" if certificate_name
        predicates << "expiry date: #{cert_date}" if cert_date

        predicates_str = " with #{predicates.join(' or ')}"

        raise "Could not find a Certificate#{predicates_str}. Please open #{current_url} and make sure you have a signing profile created.".red
      end

      # Download a file from the dev center, by using a HTTP client. This will return the content of the file
      def download_file(url)
        Helper.log.info "Downloading profile..."
        host = Capybara.current_session.current_host
        url = [host, url].join('')

        cookieString = ""
        
        page.driver.cookies.each do |key, cookie|
          cookieString << "#{cookie.name}=#{cookie.value};" # append all known cookies
        end 
        
        data = open(url, {'Cookie' => cookieString}).read

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
        system("open '#{path}'") unless ENV['SIGH_DISABLE_OPEN_ERROR']
      end

      def wait_for(method, parameter, success)
        counter = 0
        result = method.call(parameter)
        while !success.call(result)
          sleep 0.2

          result = method.call(parameter)

          counter += 1
          if counter > 100
            Helper.log.debug caller
            raise DeveloperCenterGeneralError.new("Couldn't find '#{parameter}' after waiting for quite some time")
          end
        end
        return result
      end

      def wait_for_elements(name)
        method = Proc.new { |n| all(name) }
        success = Proc.new { |r| r.count > 0 }
        return wait_for(method, name, success)
      end

      def wait_for_variable(name)
        method = Proc.new { |n|
          retval = page.html.match(/var #{n} = "(.*)"/)
          retval[1] unless retval == nil
        }
        success = Proc.new { |r| r != nil }
        return wait_for(method, name, success)
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
