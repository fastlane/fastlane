describe 'App Asset Library request retries' do
  let(:token) { double('token', text: 'test-token', expired?: false, in_house: false) }
  let(:client) { Spaceship::ConnectAPI::Tunes::Client.new(token: token) }

  {
    post_app_asset_library_image: {
      path: 'v1/appAssetLibraryImages',
      arguments: { app_asset_library_id: 'library', attributes: { fileName: 'header.png', fileSize: 5, category: 'CREATIVE_ASSETS' } }
    },
    post_app_screenshot: {
      path: 'v1/appScreenshots',
      arguments: { app_screenshot_set_id: 'screenshot-set', attributes: { fileName: 'screenshot.png', fileSize: 5 } }
    },
    post_app_asset_library_placement: {
      path: 'v1/appAssetLibraryPlacements',
      arguments: { app_store_version_localization_id: 'localization', image_id: 'image', attributes: { placementType: 'PRODUCT_PAGE_HEADER_ASSET', placementGroup: 'group' } }
    }
  }.each do |method, request|
    context method.to_s do
      let(:url) { "https://api.appstoreconnect.apple.com/#{request[:path]}" }

      [Faraday::TimeoutError, Faraday::ConnectionFailed].each do |error|
        it "sends only one POST after #{error}" do
          transport = stub_request(:post, url).to_raise(error)

          expect { client.public_send(method, **request[:arguments]) }.to raise_error(error)
          expect(transport).to have_been_requested.once
        end
      end

      [
        [503, '<h1>503 Service Temporarily Unavailable</h1>', 'text/html', Spaceship::AppleTimeoutError],
        [502, 'Could not process this request', 'text/plain', Spaceship::BadGatewayError],
        [500, '{"errors":[]}', 'application/json', Spaceship::InternalServerError],
        [504, '{"errors":[]}', 'application/json', Spaceship::InternalServerError],
        [200, '{invalid JSON', 'application/json', Faraday::ParsingError],
        [401, '{"errors":[]}', 'application/json', Spaceship::UnauthorizedAccessError],
        [403, '{"errors":[]}', 'application/json', Spaceship::AccessForbiddenError],
        [429, '{"errors":[]}', 'application/json', Spaceship::UnexpectedResponse]
      ].each do |status, body, content_type, error|
        it "sends only one POST after HTTP #{status} with #{content_type}" do
          transport = stub_request(:post, url).to_return(status: status, body: body, headers: { 'Content-Type' => content_type })
          allow(Kernel).to receive(:sleep)

          expect { client.public_send(method, **request[:arguments]) }.to raise_error(error)
          expect(transport).to have_been_requested.once
        end
      end
    end
  end

  it 'preserves default POST transport retries after a single-attempt asset request on the same client' do
    asset_request = stub_request(:post, 'https://api.appstoreconnect.apple.com/v1/appAssetLibraryImages').to_raise(Faraday::TimeoutError)
    expect { client.post_app_asset_library_image(app_asset_library_id: 'library') }.to raise_error(Faraday::TimeoutError)

    ordinary_request = stub_request(:post, 'https://api.appstoreconnect.apple.com/v1/otherResources').to_raise(Faraday::TimeoutError)
    expect { client.post('v1/otherResources', {}) }.to raise_error(Faraday::TimeoutError)

    expect(asset_request).to have_been_requested.once
    expect(ordinary_request).to have_been_requested.times(5)
  end

  it 'sends only one placement POST with cookie authentication' do
    cookie_client = Spaceship::ConnectAPI::Tunes::Client.new(cookie: HTTP::CookieJar.new)
    transport = stub_request(:post, 'https://appstoreconnect.apple.com/iris/v1/appAssetLibraryPlacements').to_raise(Faraday::TimeoutError)

    expect do
      cookie_client.post_app_asset_library_placement(app_store_version_localization_id: 'localization', image_id: 'image')
    end.to raise_error(Faraday::TimeoutError)
    expect(transport).to have_been_requested.once
  end

  it 'does not re-login and retry a single-attempt POST after a cookie-authenticated 401' do
    cookie_client = Spaceship::ConnectAPI::Tunes::Client.new(cookie: HTTP::CookieJar.new)
    cookie_client.instance_variable_set(:@loggedin, true)
    transport = stub_request(:post, 'https://appstoreconnect.apple.com/iris/v1/appAssetLibraryPlacements').
                to_return(status: 401, body: '{"errors":[]}', headers: { 'Content-Type' => 'application/json' })
    expect(cookie_client).not_to receive(:do_login)

    expect do
      cookie_client.post_app_asset_library_placement(app_store_version_localization_id: 'localization', image_id: 'image')
    end.to raise_error(Spaceship::UnauthorizedAccessError)
    expect(transport).to have_been_requested.once
  end

  it 'preserves default GET transport retries' do
    transport = stub_request(:get, 'https://api.appstoreconnect.apple.com/v1/appAssetLibraryImages/image').to_raise(Faraday::ConnectionFailed)

    expect { client.get_app_asset_library_image(app_asset_library_image_id: 'image') }.to raise_error(Faraday::ConnectionFailed)
    expect(transport).to have_been_requested.times(5)
  end

  it 'preserves default POST rate-limit backoff' do
    transport = stub_request(:post, 'https://api.appstoreconnect.apple.com/v1/otherResources').
                to_return(status: 429, body: '{"errors":[]}', headers: { 'Content-Type' => 'application/json' }).then.
                to_return(status: 201, body: '{"data":[]}', headers: { 'Content-Type' => 'application/json' })
    expect(Kernel).to receive(:sleep).with(1).once

    expect(client.post('v1/otherResources', {}).status).to eq(201)
    expect(transport).to have_been_requested.twice
  end
end
