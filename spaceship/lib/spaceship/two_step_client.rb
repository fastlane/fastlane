require 'tempfile'

module Spaceship
  class Client
    def handle_two_step(response)
      labels_regex = %r{<label class="radio-label" for="(deviceId.*?)">.*?([0-9]+)<\/.*?>}
      device_matches = response.body.scan(labels_regex)

      if device_matches.length > 0
        puts "Two Factor Verification for account '#{self.user}' is enabled"
        puts "Please select a phone to verify your identity"
        available = device_matches.collect do |match|
          "Phone number ending in #{match[1]}"
        end
        result = choose(*available)

        selected_index = 1 # omg no.
        available.each do |selected|
          break if selected == result
          selected_index += selected_index
        end

        select_device(response, selected_index)
      else
        raise "Invalid 2 step response #{response.body}"
      end
    end

    # Only needed for 2 step
    def load_session_from_file
      if File.exist?(persistent_cookie_path)
        puts "Loading session from '#{persistent_cookie_path}'" if Spaceship::Globals.verbose?
        @cookie.load(persistent_cookie_path)
        return true
      end
      return false
    end

    def load_session_from_env
      return if self.class.spaceship_session_env.to_s.length == 0
      puts "Loading session from environment variable" if Spaceship::Globals.verbose?

      file = Tempfile.new('cookie.yml')
      file.write(self.class.spaceship_session_env.gsub("\\n", "\n"))
      file.close

      begin
        @cookie.load(file.path)
      rescue => ex
        puts "Error loading session from environment"
        puts "Make sure to pass the session in a valid format"
        raise ex
      ensure
        file.unlink
      end
    end

    # Fetch the session cookie from the environment
    # (if exists)
    def self.spaceship_session_env
      ENV["FASTLANE_SESSION"] || ENV["SPACESHIP_SESSION"]
    end

    def select_device(r, device_id)
      # Request Token
      # Not quite there yet
      scnt_regex = %r{<input type="hidden" id="scnt" name="scnt" value="(.*?)" .*?\/>}
      scnt = r.body.scan(scnt_regex)[0][0]
      r = request(:post) do |req|
        req.url "https://idmsa.apple.com/IDMSWebAuth/generateSecurityCode"
        req.body = "deviceIndex=#{device_id}&scnt=#{scnt}"
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.headers['Accept'] = 'application/json, text/javascript'
      end

      raise "Too many codes sent, enter the last code you received, use a different device, or try again later" if r.body.include?("Too many codes sent")

      # we use `Spaceship::TunesClient.new.handle_itc_response`
      # since this might be from the Dev Portal, but for 2 step
      Spaceship::TunesClient.new.handle_itc_response(r.body)

      puts "Successfully requested notification"
      code = ask("Please enter the 4 digit code: ")
      puts "Requesting session..."

      # Send code back to server to get a valid session
      r = request(:post) do |req|
        req.url "https://idmsa.apple.com/IDMSWebAuth/validateSecurityCode"
        req.body = "digit1=#{code[0]}&digit2=#{code[1]}&digit3=#{code[2]}&digit4=#{code[3]}&scnt=#{scnt}"
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.headers['Accept'] = 'application/json, text/javascript'
      end

      begin
        Spaceship::TunesClient.new.handle_itc_response(r.body) # this will fail if the code is invalid
      rescue => ex
        if ex.to_s.include?("verification code") # to have a nicer output
          puts "Error: Incorrect verification code"
          return select_device(r, device_id)
        end

        raise ex
      end

      store_session
      return true
    end

    def store_session
      # If the request was successful, r.body is actually nil
      # The previous request will fail if the user isn't on a team
      # on iTunes Connect, but it still works, so we're good

      # Tell iTC that we are trustworthy (obviously)
      # This will update our local cookies to something new
      # They probably have a longer time to live than the other poor cookies
      # Changed Keys
      # - myacinfo
      # - DES5c148586dfd451e55afb0175f62418f91
      # We actually only care about the DES value

      request(:get) do |req|
        req.url "https://idmsa.apple.com/appleauth/auth/2sv/trust"

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
