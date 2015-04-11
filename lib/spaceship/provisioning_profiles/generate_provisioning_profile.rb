module Spaceship
  class Client
    # Generates the given provisioning profile
    # @param profile The provisioning profile that should be created
    # @param distribution_type Available values: 
    #  - 'limited': Development
    #  - 'adhoc': AdHoc
    #  - 'store': App Store
    # @param device_ids A string containing an array of all devices to use (optional)
    # @param certificate The signing identity to use (optional)
    def generate_provisioning_profile!(profile, distribution_type, device_ids = nil, certificate = nil)
      raise "Invalid distribution type '#{distribution_type}'".red unless ['limited', 'adhoc', 'store'].include?distribution_type
      raise "device_ids must be a string" unless (device_ids || '').kind_of?String

      url = URL_CREATE_PROVISIONING_PROFILE + @team_id

      certificate ||= get_code_signing_identity(distribution_type)

      body = {
        appIdId: profile.app.app_id,
        distributionType: distribution_type,
        certificateIds: certificate.id,
        provisioningProfileName: profile.name,
        returnFullObjects: false # this would information about return the generated profile - we don't care
      }

      body[:deviceIds] = device_ids || all_devices_for_profile unless distribution_type == 'store'

      response = Excon.post(url, 
        headers: { 
          "Cookie" => "myacinfo=#{@myacinfo}",
          "Content-Type" => "application/x-www-form-urlencoded",
          csrf: csrf,
          csrf_ts: csrf_ts
        },
        body: URI.encode_www_form(body)
      )

      handle_create_error(response) # some errors are returned in plain text
      result = JSON.parse(unzip(response))
      handle_create_error_json(result)

      if result['resultCode'] == 0
        binding.pry
        Helper.log.info "Successfully generated new provisioning profile: '#{profile.name}'".green
        return true
      end
      return false
    end

    # Returns '[XC5PH8DAAA,XC5PH8DAAA]'
    def all_devices_for_profile
      "[" + devices.collect { |a| a.id }.join(",") + "]"
    end

    # Returns a list of available code signing identities
    def get_code_signing_identity(distribution_type = nil)
      val = ProfileTypes::SigningCertificate.distribution # default distribution

      val = ProfileTypes::SigningCertificate.distribution if ['adhoc', 'store'].include?distribution_type
      val = ProfileTypes::SigningCertificate.development if ['limited'].include?distribution_type

      certs = certificates(val)

      return certs.first if certs.count == 1

      if certs.count == 0        
        raise "Couldn't find a certificate to create the given provisionging profile. You need a certificate that supports '#{distribution_type}'. You can use cert for that: https://github.com/KrauseFx/cert".red
      end

      # Multiple profiles, let user choose
      loop do
        Helper.log.info "Multiple certificates for #{distribution_type} available, choose which one you want to use".green
        certs.each_with_index do |cert, index|
          puts "\t#{index + 1}) #{cert}"
        end

        i = gets.strip.to_i - 1
        if certs[i]
          return certs[i]
        end
        Helper.log.error "Invalid input. Please enter the number of the profile you want to use".red
      end
    end

    def handle_create_error(response)
      if response.body.include?"Multiple profiles found with the name"
        raise response.body.gsub("&#x27;", '"').red
      elsif response.body.include?"There are no current certificates on this team"
        Helper.log.fatal "The following error might be caused when trying to use a development certificate for a distribution profile".red
        raise response.body.red
      end
    end

    def handle_create_error_json(response)
      if (response['validationMessages'] || []).count > 0
        raise response['userString'].gsub("&#x27;", '"').red # just throw the nice error string provided by Apple
      end
    end

    def csrf
      fetch_csrf_values
      @csrf
    end

    def csrf_ts
      fetch_csrf_values
      @csrf_ts
    end

    private
      # Fetches the csrf and csrf_ts (timestamp) and stores them in @csrf and @csrf_ts
      def fetch_csrf_values
        return if @csrf and @csrf_ts

        url = URL_GET_CSRF_VALUES + @team_id
        response = Excon.post(url, headers: {
          "Cookie" => "myacinfo=#{@myacinfo}"
        })

        @csrf = response.headers['csrf']
        @csrf_ts = response.headers['csrf_ts']
      end
  end
end
