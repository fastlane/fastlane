module Spaceship
  class TunesClient < Spaceship::Client

    #####################################################
    # @!group Init and Login
    #####################################################

    def self.hostname
      "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/"
    end

    # Fetches the latest login URL from iTunes Connect
    def login_url
      cache_path = "/tmp/spaceship_itc_login_url.txt"
      begin
        cached = File.read(cache_path) 
      rescue Errno::ENOENT
      end
      return cached if cached

      host = "https://itunesconnect.apple.com"
      begin
        url = host + request(:get, host).body.match(/action="(\/WebObjects\/iTunesConnect.woa\/wo\/.*)"/)[1]
        raise "" unless url.length > 0

        File.write(cache_path, url) # TODO
        return url
      rescue => ex
        raise "Could not fetch the login URL from iTunes Connect, the server might be down".red
      end
    end

    def send_login_request(user, password)
      response = request(:post, login_url, {
        theAccountName: user,
        theAccountPW: password
      })

      if response['Set-Cookie'] =~ /myacinfo=(\w+);/
        # To use the session properly we'll need the following cookies:
        #  - myacinfo
        #  - woinst
        #  - wosid

        begin
          cooks = response['Set-Cookie']

          to_use = [
            "myacinfo=" + cooks.match(/myacinfo=(\w+)/)[1],
            "woinst=" + cooks.match(/woinst=(\w+)/)[1],
            "wosid=" + cooks.match(/wosid=(\w+)/)[1]
          ]

          @cookie = to_use.join(';')
        rescue => ex
          # User Credentials are wrong
          raise InvalidUserCredentialsError.new(response)
        end
        

        return @client
      else
        # User Credentials are wrong
        raise InvalidUserCredentialsError.new(response)
      end
    end

    #####################################################
    # @!group Applications
    #####################################################

    def applications
      r = request(:get, 'ra/apps/manageyourapps/summary')
      parse_response(r, 'data')['summaries']
    end
  end
end