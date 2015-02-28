require 'fastlane_core/developer_center/developer_center'

module FastlaneCore
  class DeveloperCenter
    DISTRIBUTION = "Distribution"
    DEVELOPMENT = "Development"

    CERTS_URL = "https://developer.apple.com/account/ios/certificate/certificateList.action?type=distribution"
    CERTS_URL_DEV = "https://developer.apple.com/account/ios/certificate/certificateList.action?type=development"
    CREATE_CERT_URL = "https://developer.apple.com/account/ios/certificate/certificateCreate.action"

    # This will check if there is at least one of the certificates already installed on the local machine
    # This will store the resulting file name in ENV 'CER_FILE_PATH' and the Cert ID in 'CER_CERTIFICATE_ID'
    def run(type)
      file = find_existing_cert(type)
      if file
        # We don't need to do anything :)
        ENV["CER_FILE_PATH"] = file
      else
        create_certificate(type)
      end
    rescue => ex
      error_occured(ex)
    end

    def find_existing_cert(type)
      if type == DEVELOPMENT
        visit CERTS_URL_DEV
      else
        visit CERTS_URL
      end

      # Download all available certs to check if they are installed using the SHA1 hash
      certs = code_signing_certificate(type)
      certs.each do |current|
        display_id = current['certificateId']
        type_id = current['certificateTypeDisplayId']
        url = "/account/ios/certificate/certificateContentDownload.action?displayId=#{display_id}&type=#{type_id}"

        output = File.join(TMP_FOLDER, "#{display_id}-#{type_id}.cer")
        download_url(url, output)
        if Cert::CertChecker.is_installed?output
          # We'll use this one, since it's installed on the local machine
          ENV["CER_CERTIFICATE_ID"] = display_id
          Helper.log.info "Found the certificate #{display_id}-#{type_id} which is installed on the local machine. Using this one.".green
          return output
        end
      end

      Helper.log.info "Couldn't find an existing certificate... creating a new one"
      return false
    rescue => ex
      error_occured(ex)
    end

    # This will actually create a new certificate
    def create_certificate(type)
      visit CREATE_CERT_URL
      wait_for_elements("form[name='certificateSave']")

      Helper.log.info "Creating a new code signing certificate"

      # select certificate type
      toggle_value = 'type-iosNoOCSP'
      toggle_value = 'type-development' if type == DEVELOPMENT
      app_store_toggle = first("input##{toggle_value}")
      if !!app_store_toggle['disabled']
        # Limit of certificates already reached
        raise "Could not create another certificate, reached the maximum number of available certificates.".red
      end

      app_store_toggle.click

      click_next # submit the certificate type
      sleep 2
      click_next # information about how to upload the file (no action required on this step)

      cert_signing_request = Cert::SigningRequest.get_path
      Helper.log.info "Uploading the cert signing request '#{cert_signing_request}'"

      wait_for_elements("input[name='upload']").first.set cert_signing_request # upload the cert signing request
      sleep 1
      click_next

      sleep 3

      while all(:css, '.loadingMessage').count > 0
        Helper.log.debug "Waiting for iTC to generate the profile"
        sleep 2
      end

      Helper.log.info "Downloading newly generated certificate"
      sleep 2

      # Now download the certificate
      download_button = wait_for_elements(".button.small.blue").first
      url = download_button['href']

      path = File.join(TMP_FOLDER, "certificate.cer")
      download_url(url, path)

      certificate_id = url.match(/.*displayId=(.*)&type.*/)[1]

      ENV["CER_FILE_PATH"] = path
      ENV["CER_CERTIFICATE_ID"] = certificate_id
      Helper.log.info "Successfully downloaded latest .cer file to '#{path}' (#{certificate_id})".green

      Cert::KeychainImporter::import_file(path)
    rescue => ex
      error_occured(ex)
    end


    private
      def download_url(url, output_path)
        host = Capybara.current_session.current_host
        url = [host, url].join('')
        Helper.log.info "Downloading URL: '#{url}'"

        cookieString = ""
        page.driver.cookies.each do |key, cookie|
          cookieString << "#{cookie.name}=#{cookie.value};" # append all known cookies
        end  
        data = open(url, {'Cookie' => cookieString}).read

        raise "Something went wrong when downloading the certificate" unless data

        dataWritten = File.write(output_path, data)

        if dataWritten == 0
          raise "Can't write to #{output_path}"
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
        if type == DEVELOPMENT
          visit CERTS_URL_DEV
        else
          visit CERTS_URL
        end

        certificateDataURL = wait_for_variable('certificateDataURL')
        certificateRequestTypes = wait_for_variable('certificateRequestTypes')
        certificateStatuses = wait_for_variable('certificateStatuses')

        url = [certificateDataURL, certificateRequestTypes, certificateStatuses].join('')

        # https://developer.apple.com/services-account/.../account/ios/certificate/listCertRequests.action?content-type=application/x-www-form-urlencoded&accept=application/json&requestId=...&userLocale=en_US&teamId=...&types=...&status=4&certificateStatus=0&type=distribution

        available = []

        certTypeName = 'iOS Distribution'
        certTypeName = 'iOS Development' if type == DEVELOPMENT
        certs = post_ajax(url)['certRequests']
        certs.each do |current_cert|
          if current_cert['typeString'] == certTypeName
            # The other profiles are push profiles
            # We only care about the distribution profile
            available << current_cert # mostly we only care about the 'certificateId'
          end
        end

        return available
      end

      def click_next
        wait_for_elements('.button.small.blue.right.submit').last.click
      end
  end
end
