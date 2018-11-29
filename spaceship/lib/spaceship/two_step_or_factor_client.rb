require_relative 'globals'
require_relative 'tunes/tunes_client'
require_relative 'tunes/recovery_device'

module Spaceship
  class Client
    def handle_two_step_or_factor(response)
      @x_apple_id_session_id = response["x-apple-id-session-id"]
      @scnt = response["scnt"]

      puts("")
      puts("Two-step Verification (4 digits code) or Two-factor Authentication (6 digits code) is enabled for account '#{self.user}'")
      puts("More information about Two-step Verification (4 digits code): https://support.apple.com/en-us/HT204152")
      puts("More information about Two-factor Authentication (6 digits code): https://support.apple.com/en-us/HT204915")
      puts("")

      r = request(:get) do |req|
        req.url("https://idmsa.apple.com/appleauth/auth")
        update_request_headers(req)
      end

      if r.body.kind_of?(Hash) && r.body["trustedDevices"].kind_of?(Array)
        handle_two_step(r)
      elsif r.body.kind_of?(Hash) && r.body["trustedPhoneNumbers"].kind_of?(Array) && r.body["trustedPhoneNumbers"].first.kind_of?(Hash)
        handle_two_factor(r)
      else
        raise "Although response from Apple indicated activated Two-step Verification or Two-factor Authentication, spaceship didn't know how to handle this response: #{r.body}"
      end
    end

    def handle_two_step(r)
      if r.body.fetch("securityCode", {})["tooManyCodesLock"].to_s.length > 0
        raise Tunes::Error.new, "Too many verification codes have been sent. Enter the last code you received, use one of your devices, or try again later."
      end

      old_client = (begin
                      Tunes::RecoveryDevice.client
                    rescue
                      nil # since client might be nil, which raises an exception
                    end)
      Tunes::RecoveryDevice.client = self # temporary set it as it's required by the factory method
      devices = r.body["trustedDevices"].collect do |current|
        Tunes::RecoveryDevice.factory(current)
      end
      Tunes::RecoveryDevice.client = old_client

      puts("Two-step Verification (4 digits code) is enabled for account '#{self.user}'")
      puts("Please select a device to verify your identity")
      available = devices.collect do |c|
        "#{c.name}\t#{c.model_name || 'SMS'}\t(#{c.device_id})"
      end
      result = choose(*available)
      device_id = result.match(/.*\t.*\t\((.*)\)/)[1]
      select_device(r, device_id)
    end

    # this is extracted into its own method so it can be called multiple times (see end)
    def select_device(r, device_id)
      # Request Token
      r = request(:put) do |req|
        req.url("https://idmsa.apple.com/appleauth/auth/verify/device/#{device_id}/securitycode")
        update_request_headers(req)
      end

      # we use `Spaceship::TunesClient.new.handle_itc_response`
      # since this might be from the Dev Portal, but for 2 step
      Spaceship::TunesClient.new.handle_itc_response(r.body)

      puts("Successfully requested notification")
      code = ask("Please enter the 4 digit code: ")
      puts("Requesting session...")

      # Send token back to server to get a valid session
      r = request(:post) do |req|
        req.url("https://idmsa.apple.com/appleauth/auth/verify/device/#{device_id}/securitycode")
        req.headers['Content-Type'] = 'application/json'
        req.body = { "code" => code.to_s }.to_json
        update_request_headers(req)
      end

      begin
        Spaceship::TunesClient.new.handle_itc_response(r.body) # this will fail if the code is invalid
      rescue => ex
        # If the code was entered wrong
        # {
        #   "securityCode": {
        #     "code": "1234"
        #   },
        #   "securityCodeLocked": false,
        #   "recoveryKeyLocked": false,
        #   "recoveryKeySupported": true,
        #   "manageTrustedDevicesLinkName": "appleid.apple.com",
        #   "suppressResend": false,
        #   "authType": "hsa",
        #   "accountLocked": false,
        #   "validationErrors": [{
        #     "code": "-21669",
        #     "title": "Incorrect Verification Code",
        #     "message": "Incorrect verification code."
        #   }]
        # }
        if ex.to_s.include?("verification code") # to have a nicer output
          puts("Error: Incorrect verification code")
          return select_device(r, device_id)
        end

        raise ex
      end

      store_session

      return true
    end

    def handle_two_factor(response)
      two_factor_url = "https://github.com/fastlane/fastlane/tree/master/spaceship#2-step-verification"
      puts("Two-factor Authentication (6 digits code) is enabled for account '#{self.user}'")

      puts("If you're running this in a non-interactive session (e.g. server or CI)")
      puts("check out #{two_factor_url}")

      security_code = response.body["securityCode"]
      # securityCode =
      # {"length"=>6,
      #  "tooManyCodesSent"=>false,
      #  "tooManyCodesValidated"=>false,
      #  "securityCodeLocked"=>false}
      code_length = security_code["length"]
      code = ask("Please enter the #{code_length} digit code: ")
      puts("Requesting session...")

      # Send securityCode back to server to get a valid session
      r = request(:post) do |req|
        req.url("https://idmsa.apple.com/appleauth/auth/verify/trusteddevice/securitycode")
        req.headers['Content-Type'] = 'application/json'
        req.body = { "securityCode" => { "code" => code.to_s } }.to_json

        update_request_headers(req)
      end

      # we use `Spaceship::TunesClient.new.handle_itc_response`
      # since this might be from the Dev Portal, but for 2 step
      Spaceship::TunesClient.new.handle_itc_response(r.body)

      store_session

      return true
    end

    def store_session
      # If the request was successful, r.body is actually nil
      # The previous request will fail if the user isn't on a team
      # on App Store Connect, but it still works, so we're good

      # Tell iTC that we are trustworthy (obviously)
      # This will update our local cookies to something new
      # They probably have a longer time to live than the other poor cookies
      # Changed Keys
      # - myacinfo
      # - DES5c148586dfd451e55afb0175f62418f91
      # We actually only care about the DES value

      request(:get) do |req|
        req.url("https://idmsa.apple.com/appleauth/auth/2sv/trust")

        update_request_headers(req)
      end
      # This request will fail if the user isn't added to a team on iTC
      # However we don't really care, this request will still return the
      # correct DES... cookie

      self.store_cookie
    end

    # Responsible for setting all required header attributes for the requests
    # to succeed
    def update_request_headers(req)
      req.headers["X-Apple-Id-Session-Id"] = @x_apple_id_session_id
      req.headers["X-Apple-Widget-Key"] = self.itc_service_key
      req.headers["Accept"] = "application/json"
      req.headers["scnt"] = @scnt
    end
  end
end
