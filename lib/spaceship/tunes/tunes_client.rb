module Spaceship
  class TunesClient < Spaceship::Client

    # ITunesConnectError is only thrown when iTunes Connect raises an exception
    class ITunesConnectError < StandardError
    end

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
        url = host + request(:get, self.class.hostname).body.match(%r{action="(/WebObjects/iTunesConnect.woa/wo/.*)"})[1]
        raise "" unless url.length > 0

        File.write(cache_path, url)
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
        #  - itctx
        begin
          re = response['Set-Cookie']

          to_use = [
            "myacinfo=" + re.match(/myacinfo=([^;]*)/)[1],
            "woinst=" + re.match(/woinst=([^;]*)/)[1],
            "itctx=" + re.match(/itctx=([^;]*)/)[1],
            "wosid=" + re.match(/wosid=([^;]*)/)[1]
          ]

          @cookie = to_use.join(';')
        rescue
          raise ITunesConnectError.new, [response.body, response['Set-Cookie']].join("\n")
        end

        return @client
      else
        if (response.body || "").include?("You have successfully signed out")
          # User Credentials are wrong
          raise InvalidUserCredentialsError.new, "Invalid username and password combination. Used '#{user}' as the username."
        else
          info = [response.body, response['Set-Cookie']]
          raise ITunesConnectError.new, info.join("\n")
        end
      end
    end

    def handle_itc_response(raw)
      return unless raw
      return unless raw.kind_of? Hash

      data = raw['data'] || raw # sometimes it's with data, sometimes it isn't

      if data.fetch('sectionErrorKeys', []).count == 0 and
        data.fetch('sectionInfoKeys', []).count == 0 and
        data.fetch('sectionWarningKeys', []).count == 0

        logger.debug("Request was successful")
      end

      handle_response_hash = lambda do |hash|
        errors = []
        if hash.kind_of? Hash
          hash.each do |key, value|
            errors += handle_response_hash.call(value)

            if key == 'errorKeys' and value.kind_of? Array and value.count > 0
              errors += value
            end
          end
        elsif hash.kind_of? Array
          hash.each do |value|
            errors += handle_response_hash.call(value)
          end
          # else: We don't care about simple values
        end
        return errors
      end

      errors = handle_response_hash.call(data)
      errors += data.fetch('sectionErrorKeys') if data['sectionErrorKeys']

      # Sometimes there is a different kind of error in the JSON response
      # e.g. {"warn"=>nil, "error"=>["operation_failed"], "info"=>nil}
      different_error = raw.fetch('messages', {}).fetch('error', nil)
      errors << different_error if different_error

      if errors.count > 0 # they are separated by `.` by default
        raise ITunesConnectError.new, errors.join(' ')
      end

      puts data['sectionInfoKeys'] if data['sectionInfoKeys']
      puts data['sectionWarningKeys'] if data['sectionWarningKeys']

      return data
    end

    #####################################################
    # @!group Applications
    #####################################################

    def applications
      r = request(:get, 'ra/apps/manageyourapps/summary')
      parse_response(r, 'data')['summaries']
    end

    # Creates a new application on iTunes Connect
    # @param name (String): The name of your app as it will appear on the App Store.
    #   This can't be longer than 255 characters.
    # @param primary_language (String): If localized app information isn't available in an
    #   App Store territory, the information from your primary language will be used instead.
    # @param version (String): The version number is shown on the App Store and should
    #   match the one you used in Xcode.
    # @param sku (String): A unique ID for your app that is not visible on the App Store.
    # @param bundle_id (String): The bundle ID must match the one you used in Xcode. It
    #   can't be changed after you submit your first build.
    def create_application!(name: nil, primary_language: nil, version: nil, sku: nil, bundle_id: nil, bundle_id_suffix: nil, company_name: nil)
      # First, we need to fetch the data from Apple, which we then modify with the user's values
      r = request(:get, 'ra/apps/create/?appType=ios')
      data = parse_response(r, 'data')

      # Now fill in the values we have
      data['versionString']['value'] = version
      data['newApp']['name']['value'] = name
      data['newApp']['bundleId']['value'] = bundle_id
      data['newApp']['primaryLanguage']['value'] = primary_language || 'English'
      data['newApp']['vendorId']['value'] = sku
      data['newApp']['bundleIdSuffix']['value'] = bundle_id_suffix
      data['companyName']['value'] = company_name if company_name

      # Now send back the modified hash
      r = request(:post) do |req|
        req.url 'ra/apps/create/?appType=ios'
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end

      data = parse_response(r, 'data')
      handle_itc_response(data)
    end

    def create_version!(app_id, version_number)
      r = request(:post) do |req|
        req.url "ra/apps/version/create/#{app_id}"
        req.body = { version: version_number.to_s }.to_json
        req.headers['Content-Type'] = 'application/json'
      end

      parse_response(r, 'data')
    end

    def get_resolution_center(app_id)
      r = request(:get, "ra/apps/#{app_id}/resolutionCenter?v=latest")
      parse_response(r, 'data')
    end

    #####################################################
    # @!group AppVersions
    #####################################################

    def app_version(app_id, is_live)
      raise "app_id is required" unless app_id

      v_text = (is_live ? 'live' : nil)

      r = request(:get, "ra/apps/version/#{app_id}", {v: v_text})
      parse_response(r, 'data')
    end

    def update_app_version!(app_id, is_live, data)
      raise "app_id is required" unless app_id

      v_text = (is_live ? 'live' : nil)

      r = request(:post) do |req|
        req.url "ra/apps/version/save/#{app_id}?v=#{v_text}"
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end

      handle_itc_response(r.body)
    end

    #####################################################
    # @!group Build Trains
    #####################################################

    def build_trains(app_id)
      raise "app_id is required" unless app_id

      r = request(:get, "ra/apps/#{app_id}/trains/")
      parse_response(r, 'data')
    end

    def update_build_trains!(app_id, data)
      raise "app_id is required" unless app_id

      r = request(:post) do |req|
        req.url "ra/apps/#{app_id}/trains/"
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end

      handle_itc_response(r.body)
    end

    def remove_testflight_build_from_review!(app_id: nil, train: nil, build_number: nil)
      r = request(:post) do |req|
        req.url "ra/apps/#{app_id}/trains/#{train}/builds/#{build_number}/reject"
        req.body = {}.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      handle_itc_response(r.body)
    end

    def submit_testflight_build_for_review!( # Required:
                                            app_id: nil,
                                            train: nil,
                                            build_number: nil,

                                            # Required Metadata:
                                            changelog: nil,
                                            description: nil,
                                            feedback_email: nil,
                                            marketing_url: nil,
                                            first_name: nil,
                                            last_name: nil,
                                            review_email: nil,
                                            phone_number: nil,

                                            # Optional Metadata:
                                            privacy_policy_url: nil,
                                            review_user_name: nil,
                                            review_password: nil,
                                            encryption: false)

      start_url = "ra/apps/#{app_id}/trains/#{train}/builds/#{build_number}/submit/start"
      r = request(:get) do |req|
        req.url start_url
        req.headers['Content-Type'] = 'application/json'
      end
      handle_itc_response(r.body)

      build_info = r.body['data']
      # Now fill in the values provided by the user

      # First the localised values:
      build_info['testInfo']['details'].each do |current|
        current['whatsNew']['value'] = changelog
        current['description']['value'] = description
        current['feedbackEmail']['value'] = feedback_email
        current['marketingUrl']['value'] = marketing_url
        current['privacyPolicyUrl']['value'] = privacy_policy_url
        current['pageLanguageValue'] = current['language'] # There is no valid reason why we need this, only iTC being iTC
      end
      build_info['testInfo']['reviewFirstName']['value'] = first_name
      build_info['testInfo']['reviewLastName']['value'] = last_name
      build_info['testInfo']['reviewPhone']['value'] = phone_number
      build_info['testInfo']['reviewEmail']['value'] = review_email
      build_info['testInfo']['reviewUserName']['value'] = review_user_name
      build_info['testInfo']['reviewPassword']['value'] = review_password

      r = request(:post) do |req| # same URL, but a POST request
        req.url start_url
        req.body = build_info.to_json
        req.headers['Content-Type'] = 'application/json'
      end
      handle_itc_response(r.body)

      encryption_info = r.body['data']
      if encryption_info['exportComplianceRequired']
        # only sometimes this is required

        encryption_info['usesEncryption']['value'] = encryption

        r = request(:post) do |req|
          req.url "ra/apps/#{app_id}/trains/#{train}/builds/#{build_number}/submit/complete"
          req.body = encryption_info.to_json
          req.headers['Content-Type'] = 'application/json'
        end

        handle_itc_response(r.body)
      end
    end

    #####################################################
    # @!group Submit for Review
    #####################################################

    def send_app_submission(app_id, data, stage)
      raise "app_id is required" unless app_id

      r = request(:post) do |req|
        req.url "ra/apps/#{app_id}/version/submit/#{stage}"
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end

      handle_itc_response(r.body)
      parse_response(r, 'data')
    end

    #####################################################
    # @!group Testers
    #####################################################
    def testers(tester)
      url = tester.url[:index]
      r = request(:get, url)
      parse_response(r, 'data')['testers']
    end

    def testers_by_app(tester, app_id)
      url = tester.url(app_id)[:index_by_app]
      r = request(:get, url)
      parse_response(r, 'data')['users']
    end

    def create_tester!(tester: nil, email: nil, first_name: nil, last_name: nil)
      url = tester.url[:create]
      raise "Action not provided for this tester type." unless url

      tester_data = {
            emailAddress: {
              value: email
            },
            firstName: {
              value: first_name
            },
            lastName: {
              value: last_name
            },
            testing: {
              value: true
            }
          }

      data = { testers: [tester_data] }

      r = request(:post) do |req|
        req.url url
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end

      data = parse_response(r, 'data')['testers']
      handle_itc_response(data) || data[0]
    end

    def delete_tester!(tester)
      url = tester.class.url[:delete]
      raise "Action not provided for this tester type." unless url

      data = [
        {
          emailAddress: {
            value: tester.email
          },
          firstName: {
            value: tester.first_name
          },
          lastName: {
            value: tester.last_name
          },
          testing: {
            value: false
          },
          userName: tester.email,
          testerId: tester.tester_id
        }
      ]

      r = request(:post) do |req|
        req.url url
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end

      data = parse_response(r, 'data')['testers']
      handle_itc_response(data) || data[0]
    end

    def add_tester_to_app!(tester, app_id)
      update_tester_from_app!(tester, app_id, true)
    end

    def remove_tester_from_app!(tester, app_id)
      update_tester_from_app!(tester, app_id, false)
    end

    private

    def update_tester_from_app!(tester, app_id, testing)
      url = tester.class.url(app_id)[:update_by_app]
      data = {
        users: [
          {
            emailAddress: {
              value: tester.email
            },
            firstName: {
              value: tester.first_name
            },
            lastName: {
              value: tester.last_name
            },
            testing: {
              value: testing
            }
          }
        ]
      }

      r = request(:post) do |req|
        req.url url
        req.body = data.to_json
        req.headers['Content-Type'] = 'application/json'
      end

      data = parse_response(r, 'data')
      handle_itc_response(data)
    end
  end
end
