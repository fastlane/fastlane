def stub_produce
  # Stub Spaceship
  expect(Spaceship).to receive(:login).and_return(nil)
  allow(Spaceship).to receive(:client).and_return("client")
  expect(Spaceship).to receive(:select_team).and_return(nil)
  allow(Spaceship.app).to receive(:find).and_return(true)

  # Create a new App - with enabled features
  stub_request(:post, "https://idmsa.apple.com/appleauth/auth/signin?widgetKey=e0b80c3bf78523bfe80974d320935bfa30add02e1bff88ec2166c6bd5a706c42").
    with(body: "{\"accountName\":\"helmut@xxx.com\",\"password\":\"xxxx\",\"rememberMe\":true}",
        headers: { 'Accept' => 'application/json, text/javascript', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/json', 'User-Agent' => 'Spaceship 2.9.0', 'X-Requested-With' => 'XMLHttpRequest' }).
    to_return(status: 200, body: "", headers: {})
    end
