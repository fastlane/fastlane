require 'fastlane_core/developer_center/developer_center'
require 'sigh/developer_center_signing'

module FastlaneCore
  class DeveloperCenter
    # Types of certificates
    APPSTORE = "AppStore"
    ADHOC = "AdHoc"
    DEVELOPMENT = "Development"

    PROFILES_URL_DEV = "https://developer.apple.com/account/ios/profile/profileList.action?type=limited"

    
    def run(app_identifier, type, cert_name = nil, force = false)
      cert = maintain_app_certificate(app_identifier, type, force)
      
      type_name = type
      type_name = "Distribution" if type == APPSTORE # both enterprise and App Store
      cert_name ||= "#{type_name}_#{app_identifier}.mobileprovision" # default name
      cert_name += '.mobileprovision' unless cert_name.include?'mobileprovision'

      output_path = File.join(TMP_FOLDER, cert_name)
      File.write(output_path, cert)

      store_provisioning_id_in_environment(output_path) unless ENV["SIGH_SKIP_ANALYSER"]

      return output_path
    end

    def store_provisioning_id_in_environment(path)
      require 'sigh/profile_analyser'
      udid = Sigh::ProfileAnalyser.run(path)
      ENV["SIGH_UDID"] = udid if udid
    end

    def maintain_app_certificate(app_identifier, type, force)
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
              renew_profile(provisioningProfileId, type) # This one needs to be forcefully renewed
              return maintain_app_certificate(app_identifier, type, false) # recursive
            elsif current_cert['status'] == 'Active'
              return download_profile(details['provisioningProfile']['provisioningProfileId']) # this one is already finished. Just download it.
            elsif ['Expired', 'Invalid'].include? current_cert['status']
              renew_profile(current_cert['provisioningProfileId'], type) # This one needs to be renewed
              return maintain_app_certificate(app_identifier, type, false) # recursive
            end

            break
          end
        end

        Helper.log.info "Could not find existing profile. Trying to create a new one."
        # Certificate does not exist yet, we need to create a new one
        create_profile(app_identifier, type)
        # After creating the profile, we need to download it
        return maintain_app_certificate(app_identifier, type, false) # recursive

      rescue => ex
        error_occured(ex)
      end
    end

    def create_profile(app_identifier, type)
      Helper.log.info "Creating new profile for app '#{app_identifier}' for type '#{type}'.".yellow
      certificates = code_signing_certificates(type)

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
      profile_name = ENV["SIGH_PROVISIONING_PROFILE_NAME"]
      profile_name ||= [app_identifier, type].join(' ')
      fill_in "provisioningProfileName", with: profile_name
      click_next
      wait_for_elements('.row-details')
    end

    def renew_profile(profile_id, type)
      certificate = code_signing_certificates(type).first

      details_url = "https://developer.apple.com/account/ios/profile/profileEdit.action?type=&provisioningProfileId=#{profile_id}"
      Helper.log.info "Renewing provisioning profile '#{profile_id}' using URL '#{details_url}'"
      visit details_url

      Helper.log.info "Using certificate ID '#{certificate['certificateId']}' from '#{certificate['ownerName']}'"
      wait_for_elements('.selectCertificates')

      certs = all(:xpath, "//input[@type='radio' and @value='#{certificate["certificateId"]}']")
      if certs.count == 1
        certs.first.click

        if type != APPSTORE
          # Add all devices
          wait_for_elements('.selectAll.column')
          sleep 3
          first(:xpath, "//div[@class='selectAll column']/input").click # select all the devices
        end

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
  end
end
