require 'spaceship/login/select_team'

module Spaceship
  class Client
    def login(user = nil, password = nil)
      user ||= CredentialsManager::PasswordManager.shared_manager.username
      password ||= CredentialsManager::PasswordManager.shared_manager.password

      api_key = extract_api_key(fetch_login_url)
      
      login_request = Excon.post(URL_AUTHENTICATE, 
        body: URI.encode_www_form(
          appleId: user,
          accountPassword: password,
          appIdKey: api_key
        ),
        headers: { 
          "Content-Type" => "application/x-www-form-urlencoded" 
        }
      )

      @myacinfo = extract_myacinfo(login_request.headers)
      select_team # this will store the team information into @team_id

      raise "Could not login".red unless (@myacinfo and @team_id)
      Helper.log.info "Successfully logged in".green
    rescue => ex
      Helper.log.error "An error occured...".red # TODO: error message
      raise ex
    end

    # Find the URL to the login form, which contains the API key
    def fetch_login_url
      landing_page = Excon.get(URL_LOGIN_LANDING_PAGE).body
      landing_page.match(/href="(https.*IDMSWebAuth.*)"/)[1]
    end

    # Is used to extract the API key from the login URL
    def extract_api_key(url)
      url.match(/appIdKey=([0-9a-f]+)/)[1]
    end

    # Extracts the session we need from the response header
    def extract_myacinfo(headers)
      headers.to_s.match(/myacinfo=([0-9A-Za-z]*);/)[1]
    end
  end
end