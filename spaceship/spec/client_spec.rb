describe Spaceship::Client do
  class TestClient < Spaceship::Client
    def self.hostname
      "http://example.com"
    end

    def req_home
      request(:get, TestClient.hostname)
    end

    def send_login_request(_user, _password)
      true
    end
  end

  class TestResponse
    attr_accessor :body
    attr_accessor :status

    def initialize(body = nil, status = 200)
      @body = body
      @status = status
    end
  end

  let(:subject) { TestClient.new }
  let(:unauth_error) { Spaceship::Client::UnauthorizedAccessError.new }
  let(:test_uri) { "http://example.com" }

  let(:default_body) { '{foo: "bar"}' }

  def stub_client_request(error, times, status, body)
    stub_request(:get, test_uri).
      to_raise(error).times(times).then.
      to_return(status: status, body: body)
  end

  def stub_client_retry_auth(status_error, times, status_ok, body)
    stub_request(:get, test_uri).
      to_return(status: status_error, body: body).times(times).
      then.to_return(status: status_ok, body: body)
  end

  describe "the App Store Connect API key source" do
    # Apple removed the olympus endpoint this used to come from. Its own front
    # end now takes the key from the sign out redirect. See #30199.
    let(:client) { TestClient.new }
    let(:key) { "e0b80c3bf78523bfe80974d320935bfa30add02e1bff88ec2166c6bd5a706c42" }
    let(:location) { "https://idmsa.apple.com/appleauth/signout?widgetKey=#{key}&asop=destroy-session&asoc=/&rv=3" }

    before do
      allow(client).to receive(:itc_service_key_path).and_return(File.join(Dir.tmpdir, "spaceship_key_absent_spec.txt"))
      allow(File).to receive(:write)
    end

    def signout_returning(headers)
      double("connection", head: double("response", headers: headers))
    end

    it "reads the key out of the sign out redirect" do
      allow(client).to receive(:signout_connection).and_return(signout_returning("location" => location))

      expect(client.itc_service_key).to eq(key)
    end

    # The redirect points at a signout with asop=destroy-session. Asking for it
    # over the connection that carries the session cookies would end the very
    # session this method is called to establish.
    it "does not ask for it over the session carrying connection" do
      allow(client).to receive(:signout_connection).and_return(signout_returning("location" => location))
      expect(client).to_not(receive(:request))

      client.itc_service_key
    end

    it "builds a connection with no cookie jar and no redirect following" do
      handlers = client.send(:signout_connection).builder.handlers.map(&:name)

      expect(handlers.join(" ")).to_not(match(/CookieJar/i))
      expect(handlers.join(" ")).to_not(match(/FollowRedirects/i))
    end

    it "falls back to the olympus endpoint when the redirect carries no key" do
      allow(client).to receive(:signout_connection).and_return(signout_returning({}))
      expect(client).to receive(:request).and_return(double("response", status: 200, body: { "authServiceKey" => "from-olympus" }))

      expect(client.itc_service_key).to eq("from-olympus")
    end

    it "falls back when the sign out request fails outright" do
      allow(client).to receive(:signout_connection).and_raise(Faraday::ConnectionFailed.new("nope"))
      expect(client).to receive(:request).and_return(double("response", status: 200, body: { "authServiceKey" => "from-olympus" }))

      expect(client.itc_service_key).to eq("from-olympus")
    end
  end

  describe "#itc_service_key" do
    # Apple started returning 404 from the key endpoint, and every one of these
    # surfaced as "Service key is empty" wrapped in a timeout. See #30199.
    let(:key_url) { "https://appstoreconnect.apple.com/olympus/v1/app/config?hostname=itunesconnect.apple.com" }
    let(:client) { TestClient.new }

    before do
      allow(client).to receive(:itc_service_key_path).and_return(File.join(Dir.tmpdir, "spaceship_itc_service_key_spec_absent.txt"))
      # These are about the olympus endpoint, which is the fallback now.
      allow(client).to receive(:fetch_service_key_from_signout).and_return(nil)
    end

    def response_double(status, body)
      double("response", status: status, body: body)
    end

    it "reports the status when the endpoint is gone rather than an empty key" do
      allow(client).to receive(:request).and_return(response_double(404, "<html><title>Error 404 Not Found</title></html>"))

      expect { client.itc_service_key }
        .to raise_error(Spaceship::UnexpectedResponse, /returned 404/)
    end

    it "does not report a permanent failure as something worth retrying" do
      allow(client).to receive(:request).and_return(response_double(404, "<html>nope</html>"))

      # AppleTimeoutError is in with_retry's list, so raising it for a 404 costs
      # five attempts and three second sleeps before failing anyway.
      expect { client.itc_service_key }.to_not(raise_error(Spaceship::AppleTimeoutError))
    end

    it "keeps a server error retryable" do
      allow(client).to receive(:request).and_return(response_double(503, "<html>unavailable</html>"))

      expect { client.itc_service_key }
        .to raise_error(Spaceship::AppleTimeoutError, /returned 503/)
    end

    it "says the key was missing when the response was otherwise fine" do
      allow(client).to receive(:request).and_return(response_double(200, {}))

      expect { client.itc_service_key }
        .to raise_error(Spaceship::UnexpectedResponse, /no authServiceKey/)
    end

    it "does not fail the login when the key cannot be cached" do
      allow(client).to receive(:request).and_return(response_double(200, { "authServiceKey" => "e0abc" }))
      allow(File).to receive(:write).and_raise(Errno::EACCES)

      expect(client.itc_service_key).to eq("e0abc")
    end
  end

  describe "#itc_service_key_path" do
    # Guards against going back to a literal "/tmp"; the method says why.
    it "caches the key in the system temporary directory" do
      expect(TestClient.new.itc_service_key_path).to start_with(Dir.tmpdir)
    end
  end

  describe "#logger" do
    # Guards against going back to a literal "/tmp"; the method says why.
    it "writes to the system temporary directory" do
      client = TestClient.new

      FastlaneSpec::Env.with_env_values("VERBOSE" => nil) do
        expect(client.logger.instance_variable_get(:@logdev).filename)
          .to start_with(Dir.tmpdir)
      end
    end
  end

  describe 'detect_most_common_errors_and_raise_exceptions' do
    # this test is strange, the `error` has a typo "InsufficentPermissions" and is not really relevant
    it "raises Spaceship::InsufficientPermissions for InsufficentPermissions" do
      body = JSON.generate({ messages: { error: "InsufficentPermissions" } })
      stub_client_request(Spaceship::InsufficientPermissions, 6, 200, body)

      expect do
        subject.req_home
      end.to raise_error(Spaceship::InsufficientPermissions)
    end

    it "raises Spaceship::InsufficientPermissions for Forbidden" do
      body = JSON.generate({ messages: { error: "Forbidden" } })
      stub_client_request(Spaceship::InsufficientPermissions, 6, 200, body)

      expect do
        subject.req_home
      end.to raise_error(Spaceship::InsufficientPermissions)
    end

    it "raises Spaceship::InsufficientPermissions for insufficient privileges" do
      body = JSON.generate({ messages: { error: "insufficient privileges" } })
      stub_client_request(Spaceship::InsufficientPermissions, 6, 200, body)

      expect do
        subject.req_home
      end.to raise_error(Spaceship::InsufficientPermissions)
    end

    it "raises Spaceship::InternalServerError" do
      stub_client_request(Spaceship::GatewayTimeoutError, 6, 504, "<html>Internal Server - Read</html>")

      expect do
        subject.req_home
      end.to raise_error(Spaceship::GatewayTimeoutError)
    end

    it "raises Spaceship::GatewayTimeoutError for 504" do
      stub_client_request(Spaceship::GatewayTimeoutError, 6, 504, "<html>Gateway Timeout - In Read</html>")

      expect do
        subject.req_home
      end.to raise_error(Spaceship::GatewayTimeoutError)
    end

    it "raises Spaceship::BadGatewayError for 502" do
      stub_client_request(Spaceship::BadGatewayError, 6, 502, "<html>Bad Gateway</html>")

      expect do
        subject.req_home
      end.to raise_error(Spaceship::BadGatewayError)
    end

    it "raises Spaceship::AppleTimeoutError for 503" do
      stub_client_request(Spaceship::AppleTimeoutError, 6, 503, "<html>Service Unavailable</html>")

      expect do
        subject.req_home
      end.to raise_error(Spaceship::AppleTimeoutError)
    end

    it "raises Spaceship::AppleTimeoutError for 503 HTML content" do
      body = "<html><head><title>503 Service Temporarily Unavailable</title></head><body><center><h1>503 Service Temporarily Unavailable</h1></center></body>"
      stub_client_request(Spaceship::AppleTimeoutError, 6, 200, body)

      expect do
        subject.req_home
      end.to raise_error(Spaceship::AppleTimeoutError)
    end

    it "raises Spaceship::ProgramLicenseAgreementUpdated" do
      stub_client_request(Spaceship::ProgramLicenseAgreementUpdated, 6, 200, "Program License Agreement")

      expect do
        subject.req_home
      end.to raise_error(Spaceship::ProgramLicenseAgreementUpdated)
    end

    it "raises Spaceship::AccessForbiddenError" do
      stub_client_request(Spaceship::AccessForbiddenError, 6, 403, "<html>Access Denied - In Read</html>")

      expect do
        subject.req_home
      end.to raise_error(Spaceship::AccessForbiddenError)
    end

    it "raises Spaceship::ProgramLicenseAgreementUpdated" do
      stub_client_request(Spaceship::ProgramLicenseAgreementUpdated, 6, 200, "Program License Agreement")

      expect do
        subject.req_home
      end.to raise_error(Spaceship::ProgramLicenseAgreementUpdated)
    end

    it "raises Spaceship::TooManyRequestsError" do
      stub_client_request(Spaceship::TooManyRequestsError.new({}), 6, 429, "Program License Agreement")

      expect do
        subject.req_home
      end.to raise_error(Spaceship::Client::TooManyRequestsError)
    end
  end

  describe 'retry' do
    [
      Faraday::TimeoutError,
      Faraday::ConnectionFailed,
      Faraday::ParsingError,
      Spaceship::BadGatewayError,
      Spaceship::InternalServerError,
      Spaceship::GatewayTimeoutError,
      Spaceship::AccessForbiddenError
    ].each do |thrown|
      it "re-raises when retry limit reached throwing #{thrown}" do
        stub_client_request(thrown, 6, 200, nil)

        expect do
          subject.req_home
        end.to raise_error(thrown)
      end

      it "retries when #{thrown} error raised" do
        stub_client_request(thrown, 2, 200, default_body)

        expect(subject.req_home.body).to eq(default_body)
      end
    end

    it "raises AppleTimeoutError when response contains '302 Found'" do
      ClientStubbing.stub_connection_timeout_302

      expect do
        subject.req_home
      end.to raise_error(Spaceship::Client::AppleTimeoutError)
    end

    it "raises BadGatewayError when response contains 'Bad Gateway'" do
      body = <<BODY
      <!DOCTYPE html>
<html lang="en">
<head>
    <style>
        body {
            font-family: "Helvetica Neue", "HelveticaNeue", Helvetica, Arial, sans-serif;
            font-size: 15px;
            font-weight: 200;
            line-height: 20px;
            color: #4c4c4c;
            text-align: center;
        }

        .section {
            margin-top: 50px;
        }
    </style>
</head>
<body>
<div class="section">
    <h1>&#63743;</h1>

    <h3>Bad Gateway</h3>
    <p>Correlation Key: XXXXXXXXXXXXXXXXXXXX</p>
</div>
</body>
</html>
BODY
      stub_client_retry_auth(502, 1, 200, body)

      expect do
        subject.req_home
      end.to raise_error(Spaceship::Client::BadGatewayError)
    end
  end

  describe 'retry' do
    [
      Faraday::TimeoutError,
      Faraday::ConnectionFailed,
      Faraday::ParsingError,
      Spaceship::BadGatewayError,
      Spaceship::InternalServerError,
      Spaceship::GatewayTimeoutError,
      Spaceship::AccessForbiddenError
    ].each do |thrown|
      it "re-raises when retry limit reached throwing #{thrown}" do
        stub_client_request(thrown, 6, 200, nil)

        expect do
          subject.req_home
        end.to raise_error(thrown)
      end

      it "retries when #{thrown} error raised" do
        stub_client_request(thrown, 2, 200, default_body)

        expect(subject.req_home.body).to eq(default_body)
      end
    end

    it "raises AppleTimeoutError when response contains '302 Found'" do
      ClientStubbing.stub_connection_timeout_302

      expect do
        subject.req_home
      end.to raise_error(Spaceship::Client::AppleTimeoutError)
    end

    it "raises BadGatewayError when response contains 'Bad Gateway'" do
      body = <<BODY
      <!DOCTYPE html>
<html lang="en">
<head>
    <style>
        body {
            font-family: "Helvetica Neue", "HelveticaNeue", Helvetica, Arial, sans-serif;
            font-size: 15px;
            font-weight: 200;
            line-height: 20px;
            color: #4c4c4c;
            text-align: center;
        }

        .section {
            margin-top: 50px;
        }
    </style>
</head>
<body>
<div class="section">
    <h1>&#63743;</h1>

    <h3>Bad Gateway</h3>
    <p>Correlation Key: XXXXXXXXXXXXXXXXXXXX</p>
</div>
</body>
</html>
BODY
      stub_client_retry_auth(502, 1, 200, body)

      expect do
        subject.req_home
      end.to raise_error(Spaceship::Client::BadGatewayError)
    end

    it "successfully retries request after logging in again when UnauthorizedAccess Error raised" do
      subject.login
      stub_client_retry_auth(401, 1, 200, default_body)

      expect(subject.req_home.body).to eq(default_body)
    end

    it "fails to retry request if login fails in retry block when UnauthorizedAccess Error raised" do
      subject.login
      stub_client_retry_auth(401, 1, 200, default_body)

      # the next login will fail
      def subject.send_login_request(_user, _password)
        raise Spaceship::Client::UnauthorizedAccessError.new, "Faked"
      end

      expect do
        subject.req_home
      end.to raise_error(Spaceship::Client::UnauthorizedAccessError)
    end

    describe "retry when user and password not fetched from CredentialManager" do
      let(:the_user) { 'u' }
      let(:the_password) { 'p' }

      it "is able to retry and login successfully" do
        def subject.send_login_request(user, password)
          can_login = (user == 'u' && password == 'p')
          raise Spaceship::Client::UnauthorizedAccessError.new, "Faked" unless can_login
          true
        end

        subject.login(the_user, the_password)

        stub_client_retry_auth(401, 1, 200, default_body)

        expect(subject.req_home.body).to eq(default_body)
      end
    end
  end

  describe "#do_sirp" do
    it "raises Spaceship::UnexpectedResponse when body is not valid JSON, but HTTP 200" do
      stub_request(:post, "https://idmsa.apple.com/appleauth/auth/signin/init").
        to_return(status: 200, body: "<html>Something went wrong</html>", headers: { 'Content-Type' => 'text/html' })

      expect do
        subject.do_sirp("user", "password", nil)
      end.to raise_error(Spaceship::Client::UnexpectedResponse, /Expected JSON response, but got String/)
    end

    it "raises Spaceship::UnexpectedResponse when body contains serviceErrors" do
      response_body = {
        "iteration" => 0,
        "serviceErrors" => [
          {
            "code" => "-900007",
            "suppressDismissal" => false
          }
        ]
      }

      stub_request(:post, "https://idmsa.apple.com/appleauth/auth/signin/init").
        to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })

      allow(subject).to receive(:itc_service_key).and_return("fake_service_key")

      expect do
        subject.do_sirp("user", "password", nil)
      end.to raise_error(Spaceship::Client::UnexpectedResponse)
    end
  end

  describe "#log_response" do
    it 'handles ASCII-8BIT to UTF-8 encoding gracefully' do
      response = TestResponse.new([130, 5, 3120, 130, 4, 171, 160, 3, 2].pack('C*'))
      expect(subject.send(:log_response, :get, TestClient.hostname, response)).to be_truthy
    end
  end

  describe "#persistent_cookie_path" do
    # spec_helper points SPACESHIP_COOKIE_PATH at a temporary store for the
    # whole suite, so that the specs neither write a cookie to the developer's
    # home directory nor read one an earlier run left there. These examples are
    # about how the path is chosen when that variable is not set, so they have
    # to run without it. See fastlane#30184.
    around(:each) do |example|
      FastlaneSpec::Env.with_env_values("SPACESHIP_COOKIE_PATH" => nil) { example.run }
    end

    before do
      subject.login("username", "password")
    end

    after do
      ENV.delete("SPACESHIP_COOKIE_PATH")
    end

    it "uses $SPACESHIP_COOKIE_PATH when set" do
      tmp_path = Dir.mktmpdir
      FastlaneSpec::Env.with_env_values("SPACESHIP_COOKIE_PATH" => "#{tmp_path}/custom_path") do
        expect(subject.persistent_cookie_path).to eq("#{tmp_path}/custom_path/spaceship/username/cookie")
      end
    end

    it "uses home dir by default" do
      allow(subject).to receive(:directory_accessible?).with(File.expand_path("~/.fastlane")).and_return(true)
      expect(subject.persistent_cookie_path).to eq(File.expand_path("~/.fastlane/spaceship/username/cookie"))
    end

    it "supports legacy .spaceship path" do
      allow(subject).to receive(:directory_accessible?).with(File.expand_path("~/.fastlane")).and_return(false)
      allow(subject).to receive(:directory_accessible?).with(File.expand_path("~")).and_return(true)
      expect(subject.persistent_cookie_path).to eq(File.expand_path("~/.spaceship/username/cookie"))
    end

    it "uses /var/tmp if home not available" do
      allow(subject).to receive(:directory_accessible?).with(File.expand_path("~/.fastlane")).and_return(false)
      allow(subject).to receive(:directory_accessible?).with(File.expand_path("~")).and_return(false)
      allow(subject).to receive(:directory_accessible?).with(File.expand_path("/var/tmp")).and_return(true)
      expect(subject.persistent_cookie_path).to eq(File.expand_path("/var/tmp/spaceship/username/cookie"))
    end

    it "falls back to Dir.tmpdir as last resort" do
      allow(subject).to receive(:directory_accessible?).with(File.expand_path("~")).and_return(false)
      allow(subject).to receive(:directory_accessible?).with(File.expand_path("~/.fastlane")).and_return(false)
      allow(subject).to receive(:directory_accessible?).with(File.expand_path("/var/tmp")).and_return(false)
      allow(subject).to receive(:directory_accessible?).with(Dir.tmpdir).and_return(true)
      expect(subject.persistent_cookie_path).to eq("#{Dir.tmpdir}/spaceship/username/cookie")
    end
  end
end
