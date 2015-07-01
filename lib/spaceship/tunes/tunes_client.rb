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
        url = host + request(:get, self.class.hostname).body.match(/action="(\/WebObjects\/iTunesConnect.woa\/wo\/.*)"/)[1]
        raise "" unless url.length > 0

        File.write(cache_path, url) # TODO
        return url
      rescue => ex
        puts ex
        raise "Could not fetch the login URL from iTunes Connect, the server might be down"
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

    def handle_itc_response(data)
      return unless data
      return unless data.kind_of?Hash
 
      if data['sectionErrorKeys'].count == 0 and
        data['sectionInfoKeys'].count == 0 and 
        data['sectionWarningKeys'].count == 0
        
        logger.debug("Request was successful")
      end

      def handle_response_hash(hash)
        errors = []
        if hash.kind_of?Hash
          hash.each do |key, value|
            errors = errors + handle_response_hash(value)

            if key == 'errorKeys' and value.kind_of?String and value.length > 0
              errors << value
            end
          end
        elsif hash.kind_of?Array
          hash.each do |value|
            errors = errors + handle_response_hash(value)
          end
        else
          # We don't care about simple values
        end
        return errors
      end

      errors = handle_response_hash(data)
      raise errors.join('; ') if errors.count > 0

      puts data['sectionErrorKeys'] if data['sectionErrorKeys']
      puts data['sectionInfoKeys'] if data['sectionInfoKeys']
      puts data['sectionWarningKeys'] if data['sectionWarningKeys']
      
    end


    #####################################################
    # @!group Applications
    #####################################################

    def applications
      r = request(:get, 'ra/apps/manageyourapps/summary')
      parse_response(r, 'data')['summaries']
    end

    def app_version(app_id, is_live)
      raise "app_id is required" unless app_id

      v_text = (is_live ? 'live' : nil)

      r = request(:get, "ra/apps/version/#{app_id}", {v: v_text})
      parse_response(r, 'data')
    end

    def update_app_version(app_id, is_live, data)
      raise "app_id is required" unless app_id

      v_text = (is_live ? 'live' : nil)

      r = request(:post) do |req|
        req.url "ra/apps/version/save/#{app_id}?v=#{v_text}"
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      
      handle_itc_response(r.body['data'])
    end
  end
end