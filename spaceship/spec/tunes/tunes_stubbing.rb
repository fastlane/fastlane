class TunesStubbing
  class << self
    def itc_read_fixture_file(filename)
      File.read(File.join('spaceship', 'spec', 'tunes', 'fixtures', filename))
    end

    # Necessary, as we're now running this in a different context
    def stub_request(*args)
      WebMock::API.stub_request(*args)
    end

    def itc_stub_login
      # Retrieving the current login URL
      itc_service_key_path = File.expand_path("~/Library/Caches/spaceship_itc_service_key.txt")
      File.delete(itc_service_key_path) if File.exist?(itc_service_key_path)

      stub_request(:get, 'https://itunesconnect.apple.com/itc/static-resources/controllers/login_cntrl.js').
        to_return(status: 200, body: itc_read_fixture_file('login_cntrl.js'))
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa").
        to_return(status: 200, body: "")
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/wa").
        to_return(status: 200, body: "")

      # Actual login
      stub_request(:post, "https://idmsa.apple.com/appleauth/auth/signin?widgetKey=1234567890").
        with(body: { "accountName" => "spaceship@krausefx.com", "password" => "so_secret", "rememberMe" => true }.to_json).
        to_return(status: 200, body: '{}', headers: { 'Set-Cookie' => "myacinfo=abcdef;" })

      # Failed login attempts
      stub_request(:post, "https://idmsa.apple.com/appleauth/auth/signin?widgetKey=1234567890").
        with(body: { "accountName" => "bad-username", "password" => "bad-password", "rememberMe" => true }.to_json).
        to_return(status: 401, body: '{}', headers: { 'Set-Cookie' => 'session=invalid' })
    end

    def itc_stub_applications
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/manageyourapps/summary/v2").
        to_return(status: 200, body: itc_read_fixture_file('app_summary.json'), headers: { 'Content-Type' => 'application/json' })

      # Create Version stubbing
      stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/version/create/1013943394").
        with(body: "{\"version\":\"0.1\"}").
        to_return(status: 200, body: itc_read_fixture_file('create_version_success.json'), headers: { 'Content-Type' => 'application/json' })

      # Create Application
      # Pre-Fill request
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/create/v2/?platformString=ios").
        to_return(status: 200, body: itc_read_fixture_file('create_application_prefill_request.json'), headers: { 'Content-Type' => 'application/json' })

      # Actual sucess request
      stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/create/v2").
        to_return(status: 200, body: itc_read_fixture_file('create_application_success.json'), headers: { 'Content-Type' => 'application/json' })

      # Overview of application to get the versions
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/1013943394/overview").
        to_return(status: 200, body: itc_read_fixture_file('app_overview.json'), headers: { 'Content-Type' => 'application/json' })

      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/overview").
        to_return(status: 200, body: itc_read_fixture_file('app_overview.json'), headers: { 'Content-Type' => 'application/json' })

      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/1000000000/overview").
        to_return(status: 200, body: itc_read_fixture_file('app_overview_stuckinprepare.json'), headers: { 'Content-Type' => 'application/json' })

      # App Details
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/details").
        to_return(status: 200, body: itc_read_fixture_file('app_details.json'), headers: { 'Content-Type' => 'application/json' })

      # Versions History
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/stateHistory?platform=ios").
        to_return(status: 200, body: itc_read_fixture_file('app_versions_history.json'), headers: { 'Content-Type' => 'application/json' })

      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/versions/814624685/stateHistory?platform=ios").
        to_return(status: 200, body: itc_read_fixture_file('app_version_states_history.json'), headers: { 'Content-Type' => 'application/json' })
    end

    def itc_stub_ratings
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/reviews/summary?platform=ios&versionId=").
        to_return(status: 200, body: itc_read_fixture_file('ratings_summary.json'), headers: { 'Content-Type' => 'application/json' })

      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/reviews?platform=ios&storefront=US&versionId=").
        to_return(status: 200, body: itc_read_fixture_file('review_by_storefront.json'), headers: { 'Content-Type' => 'application/json' })
    end

    def itc_stub_build_details
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/buildHistory?platform=ios").
        to_return(status: 200, body: itc_read_fixture_file('build_history.json'), headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/trains/2.0.1/buildHistory?platform=ios").
        to_return(status: 200, body: itc_read_fixture_file('build_history_for_train.json'), headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/platforms/ios/trains/2.0.1/builds/4/details").
        to_return(status: 200, body: itc_read_fixture_file('build_details.json'), headers: { 'Content-Type' => 'application/json' })
    end

    def itc_stub_candiate_builds
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/versions/812106519/candidateBuilds").
        to_return(status: 200, body: itc_read_fixture_file('candiate_builds.json'), headers: { 'Content-Type' => 'application/json' })
    end

    def itc_stub_applications_first_create
      # Create First Application
      # Pre-Fill request
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/create/v2/?platformString=ios").
        to_return(status: 200, body: itc_read_fixture_file('create_application_prefill_first_request.json'), headers: { 'Content-Type' => 'application/json' })
    end

    def itc_stub_applications_broken_first_create
      stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/create/v2").
        to_return(status: 200, body: itc_read_fixture_file('create_application_first_broken.json'), headers: { 'Content-Type' => 'application/json' })
    end

    def itc_stub_broken_create
      stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/create/v2").
        to_return(status: 200, body: itc_read_fixture_file('create_application_broken.json'), headers: { 'Content-Type' => 'application/json' })
    end

    def itc_stub_broken_create_wildcard
      stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/create/v2").
        to_return(status: 200, body: itc_read_fixture_file('create_application_wildcard_broken.json'), headers: { 'Content-Type' => 'application/json' })
    end

    def itc_stub_app_versions
      # Receiving app version
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/platforms/ios/versions/813314674").
        to_return(status: 200, body: itc_read_fixture_file('app_version.json'), headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/platforms/ios/versions/113314675").
        to_return(status: 200, body: itc_read_fixture_file('app_version.json'), headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/1000000000/platforms/ios/versions/800000000").
        to_return(status: 200, body: itc_read_fixture_file('app_version.json'), headers: { 'Content-Type' => 'application/json' })
    end

    def itc_stub_app_submissions
      # Start app submission
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/versions/812106519/submit/summary").
        to_return(status: 200, body: itc_read_fixture_file('app_submission/start_success.json'), headers: { 'Content-Type' => 'application/json' })

      # Complete app submission
      stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/version/submit/complete").
        to_return(status: 200, body: itc_read_fixture_file('app_submission/complete_success.json'), headers: { 'Content-Type' => 'application/json' })
    end

    def itc_stub_app_submissions_already_submitted
      # Start app submission
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/versions/812106519/submit/summary").
        to_return(status: 200, body: itc_read_fixture_file('app_submission/start_success.json'), headers: { 'Content-Type' => 'application/json' })

      # Complete app submission
      stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/version/submit/complete").
        to_return(status: 200, body: itc_read_fixture_file('app_submission/complete_failed.json'), headers: { 'Content-Type' => 'application/json' })
    end

    def itc_stub_app_submissions_invalid
      # Start app submission
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/versions/812106519/submit/summary").
        to_return(status: 200, body: itc_read_fixture_file('app_submission/start_failed.json'), headers: { 'Content-Type' => 'application/json' })
    end

    def itc_stub_resolution_center
      # Called from the specs to simulate invalid server responses
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/resolutionCenter?v=latest").
        to_return(status: 200, body: itc_read_fixture_file('app_resolution_center.json'), headers: { 'Content-Type' => 'application/json' })

      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/platforms/ios/resolutionCenter?v=latest").
        to_return(status: 200, body: itc_read_fixture_file('app_resolution_center.json'), headers: { 'Content-Type' => 'application/json' })
    end

    def itc_stub_build_trains
      %w(internal external).each do |type|
        stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/trains/?platform=ios&testingType=#{type}").
          to_return(status: 200, body: itc_read_fixture_file('build_trains.json'), headers: { 'Content-Type' => 'application/json' })

        stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/trains/?platform=appletvos&testingType=#{type}").
          to_return(status: 200, body: itc_read_fixture_file('build_trains.json'), headers: { 'Content-Type' => 'application/json' })

        stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/trains/?testingType=#{type}").
          to_return(status: 200, body: itc_read_fixture_file('build_trains.json'), headers: { 'Content-Type' => 'application/json' })

        # Update build trains
        stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/testingTypes/#{type}/trains/").
          to_return(status: 200, body: itc_read_fixture_file('build_trains.json'), headers: { 'Content-Type' => 'application/json' })
      end
    end

    def itc_stub_testers
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/users/pre/int").
        to_return(status: 200, body: itc_read_fixture_file('testers/get_internal.json'), headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/users/pre/ext").
        to_return(status: 200, body: itc_read_fixture_file('testers/get_external.json'), headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/user/internalTesters/898536088/").
        to_return(status: 200, body: itc_read_fixture_file('testers/existing_internal_testers.json'), headers: { 'Content-Type' => 'application/json' })
    end

    def itc_stub_testflight
      %w(appletvos ios).each do |type|
        # Test information
        stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/platforms/#{type}/trains/1.0/builds/10/testInformation").
          to_return(status: 200, body: itc_read_fixture_file("testflight_build_info_#{type}.json"), headers: { 'Content-Type' => 'application/json' })

        # Reject review
        stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/platforms/#{type}/trains/1.0/builds/10/reject").
          with(body: "{}").
          to_return(status: 200, body: "{}", headers: { 'Content-Type' => 'application/json' })

        # Submission
        stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/platforms/#{type}/trains/1.0/builds/10/review/submit").
          to_return(status: 200, body: itc_read_fixture_file("testflight_submission_submit_#{type}.json"), headers: { 'Content-Type' => 'application/json' })
      end
    end

    def itc_stub_resolution_center_valid
      # Called from the specs to simulate valid server responses
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/resolutionCenter?v=latest").
        to_return(status: 200, body: itc_read_fixture_file('app_resolution_center_valid.json'), headers: { 'Content-Type' => 'application/json' })
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/platforms/ios/resolutionCenter?v=latest").
        to_return(status: 200, body: itc_read_fixture_file('app_resolution_center_valid.json'), headers: { 'Content-Type' => 'application/json' })
    end

    def itc_stub_invalid_update
      # Called from the specs to simulate invalid server responses
      stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/platforms/ios/versions/812106519").
        to_return(status: 200, body: itc_read_fixture_file('update_app_version_failed.json'), headers: { 'Content-Type' => 'application/json' })
    end

    def itc_stub_valid_update
      # Called from the specs to simulate valid server responses
      stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/platforms/ios/versions/812106519").
        to_return(status: 200, body: itc_read_fixture_file("update_app_version_success.json"),
                  headers: { "Content-Type" => "application/json" })
    end

    def itc_stub_app_version_ref
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/version/ref").
        to_return(status: 200, body: itc_read_fixture_file("app_version_ref.json"),
                  headers: { "Content-Type" => "application/json" })
    end

    def itc_stub_user_detail
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/user/detail").
        to_return(status: 200, body: itc_read_fixture_file("user_detail.json"),
                  headers: { "Content-Type" => "application/json" })
    end

    def itc_stub_sandbox_testers
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/users/iap").
        to_return(status: 200, body: itc_read_fixture_file("sandbox_testers.json"),
                  headers: { "Content-Type" => "application/json" })
    end

    def itc_stub_create_sandbox_tester
      stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/users/iap/add").
        with(body: JSON.parse(itc_read_fixture_file("create_sandbox_tester_payload.json"))).
        to_return(status: 200, body: itc_read_fixture_file("create_sandbox_tester.json"),
                  headers: { "Content-Type" => "application/json" })
    end

    def itc_stub_delete_sandbox_tester
      body = JSON.parse(itc_read_fixture_file("delete_sandbox_tester_payload.json"))
      stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/users/iap/delete").
        with(body: JSON.parse(itc_read_fixture_file("delete_sandbox_tester_payload.json")).to_json).
        to_return(status: 200, body: itc_read_fixture_file("delete_sandbox_tester.json"),
                  headers: { "Content-Type" => "application/json" })
    end

    def itc_stub_pricing_tiers
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/pricing/matrix").
        to_return(status: 200, body: itc_read_fixture_file("pricing_tiers.json"),
                  headers: { "Content-Type" => "application/json" })
    end

    def itc_stub_release_to_store
      stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/versions/812106519/releaseToStore").
        with(body: "898536088").
        to_return(status: 200, body: itc_read_fixture_file("update_app_version_success.json"),
                  headers: { "Content-Type" => "application/json" })
    end

    def itc_stub_promocodes
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/promocodes/versions").
        to_return(status: 200, body: itc_read_fixture_file("promocodes.json"),
                  headers: { "Content-Type" => "application/json" })
    end

    def itc_stub_generate_promocodes
      stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/promocodes/versions/812106519").
        to_return(status: 200, body: itc_read_fixture_file("promocodes_generated.json"),
                  headers: { "Content-Type" => "application/json" })
    end

    def itc_stub_promocodes_history
      stub_request(:get, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/promocodes/history").
        to_return(status: 200, body: itc_read_fixture_file("promocodes_history.json"),
                  headers: { "Content-Type" => "application/json" })
    end

    def itc_stub_reject_version_success
      stub_request(:post, "https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/versions/812106519/reject").
        to_return(status: 200, body: itc_read_fixture_file("reject_app_version_success.json"),
                  headers: { "Content-Type" => "application/json" })
    end
  end
end
